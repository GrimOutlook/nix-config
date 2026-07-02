#!/usr/bin/env fish

# ---------------------------------------------------------------------------- #
# -- Fish Options -------------------------------------------------------------#
# ---------------------------------------------------------------------------- #
# pfetch is used as the interactive greeting instead of fish's default banner.
set -g fish_greeting

# Migrated from the previous bash setup's `shopt` options. Most of them have
# no fish equivalent because fish already behaves this way (or better) out of
# the box:
#   - cdspell/dirspell: fish's completion is already fuzzy/typo-tolerant.
#   - checkjobs: fish already warns about running/stopped jobs on exit.
#   - histappend: fish always appends to and shares history across sessions.
#   - histreedit/histverify: these relate to bash's `!`-style history
#     expansion, which fish deliberately doesn't have.

# Migrated from ble.sh's `ble-sabbrev L='| less'`.
abbr --add L '| less'
