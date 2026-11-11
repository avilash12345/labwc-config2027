#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Waybar · volume
#  Always prints a visible pill, even when no audio server exists.
#    volume.sh            → JSON for Waybar
#    volume.sh up|down    → change volume
#    volume.sh mute       → toggle mute
# ─────────────────────────────────────────────────────────────
set -u

ICON_HIGH=$(printf '\uf028')
ICON_LOW=$(printf '\uf027')
ICON_MUTE=$(printf '\uf026')
COLOR_OK="#8be9fd"
COLOR_MUTED="#ff5555"
COLOR_OFF="#6272a4"

have() { command -v "$1" >/dev/null 2>&1; }

# ── actions ──────────────────────────────────────────────────
action="${1:-}"

if have wpctl; then
    case "$action" in
        up)   wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ >/dev/null 2>&1 ;;
        down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- >/dev/null 2>&1 ;;
        mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle >/dev/null 2>&1 ;;
    esac
elif have pactl; then
    case "$action" in
        up)   pactl set-sink-volume @DEFAULT_SINK@ +5% >/dev/null 2>&1 ;;
        down) pactl set-sink-volume @DEFAULT_SINK@ -5% >/dev/null 2>&1 ;;
        mute) pactl set-sink-mute @DEFAULT_SINK@ toggle >/dev/null 2>&1 ;;
    esac
elif have amixer; then
    case "$action" in
        up)   amixer -q sset Master 5%+ >/dev/null 2>&1 ;;
        down) amixer -q sset Master 5%- >/dev/null 2>&1 ;;
        mute) amixer -q sset Master toggle >/dev/null 2>&1 ;;
    esac
fi

[ -n "$action" ] && exit 0

# ── read state ───────────────────────────────────────────────
volume=""
muted=0
server=0

if have wpctl; then
    out=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
    if [ -n "$out" ]; then
        server=1
        volume=$(awk '{printf "%d", $2 * 100}' <<<"$out")
        case "$out" in *MUTED*) muted=1 ;; esac
    fi
fi

if [ "$server" -eq 0 ] && have pactl; then
    out=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null)
    if [ -n "$out" ]; then
        server=1
        volume=$(grep -o '[0-9]\+%' <<<"$out" | head -1 | tr -d '%')
        if pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -q yes; then
            muted=1
        fi
    fi
fi

if [ "$server" -eq 0 ] && have amixer; then
    out=$(amixer get Master 2>/dev/null)
    if [ -n "$out" ]; then
        server=1
        volume=$(grep -o '\[[0-9]\+%\]' <<<"$out" | head -1 | tr -dc '0-9')
        if grep -q '\[off\]' <<<"$out"; then
            muted=1
        fi
    fi
fi

# ── render ───────────────────────────────────────────────────
if [ "$server" -eq 0 ]; then
    text="<span foreground='${COLOR_OFF}'>${ICON_MUTE}</span>  —"
    printf '{"text":"%s","tooltip":"No audio device detected","class":"unavailable"}\n' "$text"
    exit 0
fi

[ -z "$volume" ] && volume=0

if [ "$muted" -eq 1 ]; then
    text="<span foreground='${COLOR_MUTED}'>${ICON_MUTE}</span>  muted"
    printf '{"text":"%s","tooltip":"Muted · %s%%","class":"muted"}\n' "$text" "$volume"
elif [ "$volume" -lt 40 ]; then
    text="<span foreground='${COLOR_OK}'>${ICON_LOW}</span>  ${volume}%"
    printf '{"text":"%s","tooltip":"Volume · %s%%","class":"low"}\n' "$text" "$volume"
else
    text="<span foreground='${COLOR_OK}'>${ICON_HIGH}</span>  ${volume}%"
    printf '{"text":"%s","tooltip":"Volume · %s%%","class":"high"}\n' "$text" "$volume"
fi
