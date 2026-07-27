#!/usr/bin/env bash
# Claude Code status line: context usage + session/weekly token budget
input=$(cat)

esc=$'\033'
reset="${esc}[0m"
bold="${esc}[1m"
dim="${esc}[38;5;240m"
bar_empty="${esc}[38;5;237m"

# distinct hue per segment label
label_ctx="${esc}[38;5;81m"    # cyan
label_ses="${esc}[38;5;141m"   # purple
label_wk="${esc}[38;5;215m"    # orange

# percentage -> severity color (green -> yellow -> orange -> red)
pct_color() {
  local p="$1"
  if   [ "$p" -ge 90 ]; then printf '%s' "${esc}[38;5;203m"
  elif [ "$p" -ge 75 ]; then printf '%s' "${esc}[38;5;209m"
  elif [ "$p" -ge 50 ]; then printf '%s' "${esc}[38;5;221m"
  else                       printf '%s' "${esc}[38;5;114m"
  fi
}

# render a small filled/empty bar in the severity color
bar() {
  local p="$1" width=8 filled i out color
  color=$(pct_color "$p")
  filled=$(( (p * width + 50) / 100 ))
  [ "$filled" -gt "$width" ] && filled=$width
  [ "$filled" -lt 0 ] && filled=0
  out="${dim}▕${color}"
  for ((i = 0; i < filled; i++)); do out+="█"; done
  out+="${bar_empty}"
  for ((i = filled; i < width; i++)); do out+="░"; done
  out+="${dim}▏${reset}"
  printf '%s' "$out"
}

fmt_resets() {
  local resets_at="$1" now diff mins hrs
  now=$(date +%s)
  diff=$((resets_at - now))
  [ "$diff" -gt 0 ] || return
  mins=$(( diff / 60 ))
  hrs=$(( mins / 60 ))
  mins=$(( mins % 60 ))
  if [ "$hrs" -gt 0 ]; then
    printf ' %s(resets %dh%dm)%s' "$dim" "$hrs" "$mins" "$reset"
  else
    printf ' %s(resets %dm)%s' "$dim" "$mins" "$reset"
  fi
}

# label + bar + percentage, all colorized
segment() {
  local label_color="$1" label="$2" pct="$3" resets_at="$4"
  local reset_str="" color
  color=$(pct_color "$pct")
  [ -n "$resets_at" ] && reset_str=$(fmt_resets "$resets_at")
  printf '%s%s%s%s %s %s%s%d%%%s%s' \
    "$bold" "$label_color" "$label" "$reset" \
    "$(bar "$pct")" \
    "$bold" "$color" "$pct" "$reset" \
    "$reset_str"
}

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')

week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

parts=()

if [ -n "$used" ]; then
  parts+=("$(segment "$label_ctx" "Ctx" "$(printf '%.0f' "$used")" "")")
fi

if [ -n "$five_pct" ]; then
  parts+=("$(segment "$label_ses" "Session" "$(printf '%.0f' "$five_pct")" "$five_reset")")
fi

if [ -n "$week_pct" ]; then
  parts+=("$(segment "$label_wk" "Week" "$(printf '%.0f' "$week_pct")" "$week_reset")")
fi

if [ ${#parts[@]} -gt 0 ]; then
  out="${parts[0]}"
  for p in "${parts[@]:1}"; do
    out="${out} ${dim}│${reset} ${p}"
  done
  echo "$out"
fi
