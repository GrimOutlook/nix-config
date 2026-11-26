#!/usr/bin/env python3
"""Read Corsair 1b1c:2b2a battery status; never changes mouse settings.

CompX report-8 protocol reference:
https://github.com/HeyOkay/HaloBattery/issues/290
"""
import argparse
import json
import os
from pathlib import Path
import select
import sys
import time

VID, PID = 0x1B1C, 0x2B2A


def request():
    frame = [8, 4] + [0] * 14
    return bytes(frame + [(0x55 - sum(frame)) & 0xFF])


def parse_reply(reply):
    if len(reply) != 17 or reply[:2] != bytes([8, 4]):
        return None
    if sum(reply) & 0xFF != 0x55 or reply[6] > 100:
        return None
    return {"percentage": reply[6], "charging": bool(reply[7]),
            "voltage_mv": int.from_bytes(reply[8:10], "big")}


def query():
    # Match only this receiver and its vendor control report, not mouse/keyboard
    # input interfaces. Linux hidraw exposes all collections on an interface.
    devices = []
    for node in Path("/sys/class/hidraw").glob("hidraw*"):
        identity = (node / "device/uevent").read_text()
        if "HID_ID=0003:00001B1C:00002B2A" not in identity:
            continue
        descriptor = (node / "device/report_descriptor").read_bytes()
        if bytes.fromhex("0602ff0902a1018508") in descriptor:
            devices.append(Path("/dev") / node.name)
    if not devices:
        return {"status": "unavailable", "error": "Receiver control interface not found"}
    fd = os.open(devices[0], os.O_RDWR | os.O_NONBLOCK)
    try:
        for _ in range(4):
            if not select.select([fd], [], [], 0.03)[0]:
                break
            os.read(fd, 64)
        if os.write(fd, request()) != 17:
            raise OSError("Incomplete battery-query write")
        deadline = time.monotonic() + 1.5
        while time.monotonic() < deadline:
            if not select.select([fd], [], [], 0.25)[0]:
                continue
            reply = os.read(fd, 64)
            result = parse_reply(reply)
            if result is not None:
                return {"status": "ok", **result}
        return {"status": "unavailable", "error": "No battery reply; wake the mouse and retry"}
    finally:
        os.close(fd)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", action="store_true", help="Print machine-readable status")
    args = parser.parse_args()
    try:
        result = query()
    except (OSError, ValueError) as exc:
        result = {"status": "error", "error": str(exc)}
    if args.json:
        print(json.dumps(result))
    elif result["status"] == "ok":
        print(f"Corsair Sabre: {result['percentage']}%" +
              (" (charging)" if result["charging"] else ""))
    else:
        print(result["error"], file=sys.stderr)
    return 0 if result["status"] == "ok" else 1


if __name__ == "__main__":
    sys.exit(main())
