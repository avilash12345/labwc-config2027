#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Waybar · battery
#  Shows a battery when present; on desktops/VMs falls back to AC.
# ─────────────────────────────────────────────────────────────
set -u

BAT=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1)

# ── no battery: report AC power so the pill stays visible ────
if [ -z "$BAT" ]; then
    icon=$(printf '\uf0e7')
    text="<span foreground='#f1fa8c'>${icon}</span>  AC"
    printf '{"text":"%s","tooltip":"No battery · running on AC power","class":"ac"}\n' "$text"
    exit 0
fi

capacity=$(cat "$BAT/capacity" 2>/dev/null || echo 0)
status=$(cat "$BAT/status" 2>/dev/null || echo Unknown)

case "$capacity" in
    ''|*[!0-9]*) capacity=0 ;;
esac

# ── icon by charge level ─────────────────────────────────────
if [ "$capacity" -ge 95 ]; then
    icon=$(printf '\uf240')
elif [ "$capacity" -ge 75 ]; then
    icon=$(printf '\uf241')
elif [ "$capacity" -ge 50 ]; then
    icon=$(printf '\uf242')
elif [ "$capacity" -ge 25 ]; then
    icon=$(printf '\uf243')
else
    icon=$(printf '\uf244')
fi

# ── colour / class ───────────────────────────────────────────
case "$status" in
    Charging|Full)
        color="#50fa7b"
        class="charging"
        ;;
    *)
        if [ "$capacity" -le 10 ]; then
            color="#ff5555"
            class="critical"
        elif [ "$capacity" -le 25 ]; then
            color="#ffb86c"
            class="warning"
        else
            color="#50fa7b"
            class="discharging"
        fi
        ;;
esac

text="<span foreground='${color}'>${icon}</span>  ${capacity}%"
printf '{"text":"%s","tooltip":"Battery · %s%% (%s)","class":"%s"}\n' \
    "$text" "$capacity" "$status" "$class"
