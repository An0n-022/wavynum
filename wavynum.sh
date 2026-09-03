#!/usr/bin/env bash

# wavynum - animated number waves for terminal-focused Linux rice setups.

set -u

PROGRAM=${0##*/}
FPS=12
WAVES=3
PALETTE=cyan
DIGITS=0123456789

usage() {
    cat <<EOF
Usage: $PROGRAM [options]

Draw animated waves made from numbers in your terminal.

Options:
  -c, --color NAME    cyan, green, blue, purple, amber, white, or rainbow
                      (default: cyan)
  -s, --speed FPS     animation speed from 1 to 30 (default: 12)
  -w, --waves COUNT   number of waves from 1 to 5 (default: 3)
  -n, --numbers TEXT  characters used to draw the waves (default: 0123456789)
  -h, --help          show this help

Press q or Ctrl+C to quit.
EOF
}

die() {
    printf '%s: %s\n' "$PROGRAM" "$1" >&2
    exit 1
}

while (($#)); do
    case $1 in
        -c|--color)
            (($# >= 2)) || die "$1 requires a value"
            PALETTE=$2
            shift 2
            ;;
        -s|--speed)
            (($# >= 2)) || die "$1 requires a value"
            FPS=$2
            shift 2
            ;;
        -w|--waves)
            (($# >= 2)) || die "$1 requires a value"
            WAVES=$2
            shift 2
            ;;
        -n|--numbers)
            (($# >= 2)) || die "$1 requires a value"
            DIGITS=$2
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "unknown option: $1 (try --help)"
            ;;
    esac
done

[[ $FPS =~ ^[0-9]+$ ]] && ((FPS >= 1 && FPS <= 30)) || \
    die "speed must be a whole number from 1 to 30"
[[ $WAVES =~ ^[0-9]+$ ]] && ((WAVES >= 1 && WAVES <= 5)) || \
    die "waves must be a whole number from 1 to 5"
[[ -n $DIGITS ]] || die "numbers cannot be empty"
[[ -t 1 ]] || die "output must be an interactive terminal"

case $PALETTE in
    cyan)   BASE_COLOR=$'\e[38;5;51m' ;;
    green)  BASE_COLOR=$'\e[38;5;82m' ;;
    blue)   BASE_COLOR=$'\e[38;5;75m' ;;
    purple) BASE_COLOR=$'\e[38;5;177m' ;;
    amber)  BASE_COLOR=$'\e[38;5;214m' ;;
    white)  BASE_COLOR=$'\e[38;5;255m' ;;
    rainbow) BASE_COLOR='' ;;
    *) die "unknown color '$PALETTE' (try --help)" ;;
esac

RESET=$'\e[0m'
DIM=$'\e[2m'
FRAME_DELAY=$(awk -v fps="$FPS" 'BEGIN { printf "%.4f", 1 / fps }')
CHAR_COUNT=${#DIGITS}

# A compact integer sine table keeps the animation dependency-free and fast.
SINE=(0 1 1 2 2 3 3 4 4 4 4 4 4 4 3 3 2 2 1 1 0 -1 -1 -2 -2 -3 -3 -4 -4 -4 -4 -4 -4 -4 -3 -3 -2 -2 -1 -1)
SINE_LEN=${#SINE[@]}

cleanup() {
    printf '%s%s%s' "$RESET" $'\e[?25h' $'\e[?1049l'
}

trap cleanup EXIT INT TERM HUP

# Use the alternate screen and hide the cursor, leaving the shell clean on exit.
printf '%s%s' $'\e[?1049h' $'\e[?25l'

phase=0
frame=0
while :; do
    width=$(tput cols 2>/dev/null || printf '80')
    height=$(tput lines 2>/dev/null || printf '24')
    ((width > 160)) && width=160
    ((height > 60)) && height=60

    output=$'\e[H'
    for ((row = 0; row < height; row++)); do
        line=''
        for ((col = 0; col < width; col++)); do
            pixel=' '
            pixel_color=$BASE_COLOR

            for ((wave = 0; wave < WAVES; wave++)); do
                center=$(( (wave + 1) * height / (WAVES + 1) ))
                sine_index=$(( (col + phase + wave * 11) % SINE_LEN ))
                wave_height=${SINE[$sine_index]}
                y=$((center + wave_height))
                distance=$((row - y))
                ((distance < 0)) && distance=$((-distance))

                if ((distance <= 1)); then
                    char_index=$(( (col + row + phase + wave) % CHAR_COUNT ))
                    pixel=${DIGITS:char_index:1}
                    ((distance == 1)) && pixel_color="${DIM}${BASE_COLOR}"
                    if [[ $PALETTE == rainbow ]]; then
                        color_number=$((16 + (col * 6 / (width > 0 ? width : 1) + wave * 36 + phase) % 216))
                        pixel_color=$'\e[38;5;'"${color_number}"'m'
                        ((distance == 1)) && pixel_color="${DIM}${pixel_color}"
                    fi
                    break
                fi
            done

            if [[ $pixel == ' ' ]]; then
                line+=' '
            else
                line+="${pixel_color}${pixel}${RESET}"
            fi
        done
        output+="$line"
        ((row + 1 < height)) && output+=$'\n'
    done

    printf '%s' "$output"
    ((phase = (phase + 1) % SINE_LEN))
    ((frame++))

    # Non-blocking key check gives q a responsive exit without disturbing FPS.
    if IFS= read -rsn1 -t "$FRAME_DELAY" key && [[ $key == q || $key == Q ]]; then
        break
    fi
done
