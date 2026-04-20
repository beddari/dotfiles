#!/bin/bash
# theme-preview.sh — Preview prompt + ls output for each Ghostty theme
#
# Renders simulated terminal output using 24-bit truecolor escapes,
# showing how dircolors and starship prompt colors look in each theme.
#
# Assumes bold-is-bright=false (Ghostty default): bold text uses
# palette[0-7] with heavier font weight, not palette[8-15].
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
W=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}
CMD="${*:-ls -la $SCRIPT_DIR}"

E=$'\033'
RST="${E}[0m"
BLD="${E}[1m"
NBD="${E}[22m"

hfg() { printf "${E}[38;2;%d;%d;%dm" "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }
hbg() { printf "${E}[48;2;%d;%d;%dm" "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"; }

# Fill line with themed bg, overwrite with content, reset
emit() { printf '%s%*s\r%s%s\n' "$BG" "$W" "" "$1" "$RST"; }

for tf in "$SCRIPT_DIR"/ghostty/themes/*; do
    name=$(basename "$tf")
    pal=() bg= fg=
    while IFS= read -r line; do
        line=${line//$'\r'/}
        [[ "$line" =~ ^palette\ =\ ([0-9]+)=#(.*) ]] && pal[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"
        [[ "$line" =~ ^background\ =\ \#(.*) ]] && bg="${BASH_REMATCH[1]}"
        [[ "$line" =~ ^foreground\ =\ \#(.*) ]] && fg="${BASH_REMATCH[1]}"
    done < "$tf"

    case "$name" in *light*|*day*) v=light ;; *) v=dark ;; esac

    BG=$(hbg "$bg")
    FG=$(hfg "$fg")

    # dircolors: dark uses bold weight, light uses normal
    if [[ $v == dark ]]; then
        DC="${BLD}$(hfg "${pal[4]}")"   # DIR: bold blue
        XC="${BLD}$(hfg "${pal[2]}")"   # EXEC: bold green
    else
        DC="$(hfg "${pal[4]}")"         # DIR: blue
        XC="$(hfg "${pal[2]}")"         # EXEC: green
    fi
    NF="${NBD}${FG}"  # restore: no-bold + default fg

    # Starship named colors → palette indices
    CY=$(hfg "${pal[6]}")   # cyan  (directory path)
    MA=$(hfg "${pal[5]}")   # magenta (git branch + character)
    YE=$(hfg "${pal[3]}")   # yellow (git status)

    printf "${RST}\n  ${BLD}── %s (%s) ──${RST}\n" "$name" "$v"
    emit ""

    # Prompt + command
    emit " ${CY}~/kode/dotfiles ${MA}main ${YE}! ${MA}❯${FG} $CMD"

    # Command output (colorized: directories=blue, executables=green)
    eval "$CMD" 2>&1 | while IFS= read -r l; do
        case "$l" in
            total*) emit " $FG$l" ;;
            d*)     emit " $FG${l% *} $DC${l##* }$NF" ;;
            *x*)    emit " $FG${l% *} $XC${l##* }$NF" ;;
            *)      emit " $FG$l" ;;
        esac
    done

    # Trailing prompt
    emit " ${CY}~/kode/dotfiles ${MA}main ${YE}! ${MA}❯${FG} "
    emit ""
done

printf "${RST}\n"
