#!/usr/bin/env python3
"""Report how much disk space Frigate recordings use, broken down by the
retention category each 10-second segment belongs to: alert, detection,
motion, or continuous (no motion).

Frigate does not store recordings in per-category folders; every segment is a
file under <media>/recordings/. The category is a retention concept derived
from the SQLite DB: recordings.segment_size / recordings.motion plus the
reviewsegment table (severity = alert | detection). Each segment is attributed
to its highest-precedence category: alert > detection > motion > continuous.
"""
import argparse
import bisect
import datetime as dt
import os
import shutil
import sqlite3
import subprocess
import sys
import tempfile
from collections import defaultdict

DEFAULT_DB = os.environ.get("FRIGATE_DB", "/var/lib/frigate-config/frigate.db")
DEFAULT_MEDIA = os.environ.get("FRIGATE_MEDIA", "/nvr")
MB_PER_GIB = 1024.0

CATEGORIES = ("alert", "detection", "motion", "continuous")


def snapshot_db(src):
    """Copy the DB (plus -wal/-shm) to a temp dir so we can read a consistent
    view read-only while Frigate keeps writing in WAL mode."""
    tmp = tempfile.mkdtemp(prefix="frigate-storage-")
    dst = os.path.join(tmp, "frigate.db")
    for suffix in ("", "-wal", "-shm"):
        s = src + suffix
        if os.path.exists(s):
            shutil.copy2(s, dst + suffix)
    return tmp, dst


def load_intervals(cur, severity):
    """Return (merged_intervals, start_keys) for a review severity."""
    rows = cur.execute(
        "SELECT start_time, end_time FROM reviewsegment "
        "WHERE severity = ? AND end_time IS NOT NULL",
        (severity,),
    ).fetchall()
    ivs = sorted((float(s), float(e)) for s, e in rows)
    merged = []
    for s, e in ivs:
        if merged and s <= merged[-1][1]:
            merged[-1][1] = max(merged[-1][1], e)
        else:
            merged.append([s, e])
    starts = [m[0] for m in merged]
    return merged, starts


def overlaps(merged, starts, s, e):
    """True if [s, e] overlaps any merged (disjoint, sorted) interval."""
    if not merged:
        return False
    i = bisect.bisect_right(starts, e) - 1
    return i >= 0 and merged[i][1] >= s


def human_gib(mb):
    return f"{mb / MB_PER_GIB:,.1f}G"


def classify(db_path, per_camera):
    con = sqlite3.connect(db_path)
    cur = con.cursor()

    alert = load_intervals(cur, "alert")
    det = load_intervals(cur, "detection")

    size = defaultdict(float)
    count = defaultdict(int)
    cam_size = defaultdict(lambda: defaultdict(float))

    for st, et, sz, motion, camera in cur.execute(
        "SELECT start_time, end_time, segment_size, motion, camera "
        "FROM recordings",
    ):
        st = float(st)
        et = float(et)
        sz = sz or 0.0
        if overlaps(*alert, st, et):
            cat = "alert"
        elif overlaps(*det, st, et):
            cat = "detection"
        elif (motion or 0) > 0:
            cat = "motion"
        else:
            cat = "continuous"
        size[cat] += sz
        count[cat] += 1
        if per_camera:
            cam_size[camera][cat] += sz

    coverage = cur.execute(
        "SELECT MIN(start_time), MAX(start_time) FROM recordings"
    ).fetchone()
    con.close()
    return size, count, cam_size, coverage


def print_table(size, count):
    total = sum(size.values()) or 1.0
    print(f"{'category':<14}{'size':>12}{'segments':>14}{'share':>9}")
    print("-" * 49)
    for cat in CATEGORIES:
        print(
            f"{cat:<14}{human_gib(size[cat]):>12}"
            f"{count[cat]:>14,}{100 * size[cat] / total:>8.1f}%"
        )
    print("-" * 49)
    print(
        f"{'TOTAL':<14}{human_gib(sum(size.values())):>12}"
        f"{sum(count.values()):>14,}"
    )
    print(f"\n(~{sum(size.values()) / MB_PER_GIB / 1024:.2f} TiB in recordings)")


def print_per_camera(cam_size):
    print("\nper-camera (GiB):")
    header = f"{'camera':<16}" + "".join(f"{c:>12}" for c in CATEGORIES) + f"{'total':>12}"
    print(header)
    print("-" * len(header))
    for cam in sorted(cam_size):
        row = cam_size[cam]
        cells = "".join(f"{row[c] / MB_PER_GIB:>12,.1f}" for c in CATEGORIES)
        tot = sum(row.values()) / MB_PER_GIB
        print(f"{cam:<16}{cells}{tot:>12,.1f}")


def print_physical(media):
    """du of the on-disk media tree (needs read access to <media>)."""
    print(f"\nphysical usage under {media} (du):")
    try:
        out = subprocess.run(
            ["du", "-h", "--max-depth=1", media],
            capture_output=True, text=True, check=True,
        ).stdout.strip()
        for line in sorted(out.splitlines(), key=lambda x: x.split()[0]):
            print("  " + line)
    except (subprocess.CalledProcessError, PermissionError) as e:
        print(f"  (unavailable: {e}; run as root to read {media})")
    except FileNotFoundError:
        print(f"  ({media} not found)")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--db", default=DEFAULT_DB, help=f"Frigate DB (default {DEFAULT_DB})")
    ap.add_argument("--media", default=DEFAULT_MEDIA,
                    help=f"Frigate media dir for du (default {DEFAULT_MEDIA})")
    ap.add_argument("--per-camera", action="store_true", help="break down by camera")
    ap.add_argument("--no-du", action="store_true", help="skip physical du of media dir")
    args = ap.parse_args()

    if not os.path.exists(args.db):
        sys.exit(f"error: DB not found: {args.db}")

    tmp, snap = snapshot_db(args.db)
    try:
        size, count, cam_size, coverage = classify(snap, args.per_camera)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

    print_table(size, count)
    if args.per_camera:
        print_per_camera(cam_size)

    mn, mx = coverage
    if mn and mx:
        a = dt.datetime.fromtimestamp(float(mn))
        b = dt.datetime.fromtimestamp(float(mx))
        days = (b - a).total_seconds() / 86400
        print(f"\ncoverage: {a:%Y-%m-%d %H:%M} -> {b:%Y-%m-%d %H:%M}  ({days:.1f} days)")

    if not args.no_du:
        print_physical(args.media)


if __name__ == "__main__":
    main()
