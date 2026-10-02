#!/bin/bash


# Detect OS once at the start
IS_MAC=false
[[ "$OSTYPE" == "darwin"* ]] && IS_MAC=true

# Helper function to handle cross-platform date offsets
get_offset_time() {
  local minutes=${1:-0}
  if $IS_MAC; then
    #date -v "+${minutes}M" '+%H:%M'
    date -v "+${minutes}M" '+%d/%m/%Y %H:%M'
  else
    #date -d "${minutes} minutes" '+%H:%M'
    date -d "${minutes} minutes" '+%d/%m/%Y %H:%M'
  fi
}

get_epoch() {
  local input_str="$1"
  # Try GNU date (Linux)
  if $IS_MAC; then
    # Try BSD date (macOS) - assumes input is DD/MM/YYYY HH:MM
    date -j -f "%d/%m/%Y %H:%M" "$input_str" +%s
  else
    date -d "$(echo "$input_str" | sed 's/\//-/g')" +%s
  fi
}


if [[ -t 1 ]]; then
  if command -v tput >/dev/null 2>&1; then
    : ${FG_BLACK:=$(tput setaf 0)}
    : ${FG_RED:=$(tput setaf 1)}
    : ${FG_GREEN:=$(tput setaf 2)}
    : ${FG_YELLOW:=$(tput setaf 3)}
    : ${FG_BLUE:=$(tput setaf 4)}
    : ${FG_MAGENTA:=$(tput setaf 5)}
    : ${FG_CYAN:=$(tput setaf 6)}
    : ${FG_LIGHTGRAY:=$(tput setaf 7)}
    : ${FG_GRAY:=$(tput setaf 8)}
    : ${FG_LIGHTRED:=$(tput setaf 9)}
    : ${FG_LIGHTGREEN:=$(tput setaf 10)}
    : ${FG_LIGHTYELLOW:=$(tput setaf 11)}
    : ${FG_LIGHTBLUE:=$(tput setaf 12)}
    : ${FG_LIGHTMAGENTA:=$(tput setaf 13)}
    : ${FG_LIGHTCYAN:=$(tput setaf 14)}
    : ${FG_WHITE:=$(tput setaf 15)}

    : ${BG_BLACK:=$(tput setab 0)}
    : ${BG_RED:=$(tput setab 1)}
    : ${BG_GREEN:=$(tput setab 2)}
    : ${BG_YELLOW:=$(tput setab 3)}
    : ${BG_BLUE:=$(tput setab 4)}
    : ${BG_MAGENTA:=$(tput setab 5)}
    : ${BG_CYAN:=$(tput setab 6)}
    : ${BG_LIGHTGRAY:=$(tput setab 7)}
    : ${BG_GRAY:=$(tput setab 8)}
    : ${BG_LIGHTRED:=$(tput setab 9)}
    : ${BG_LIGHTGREEN:=$(tput setab 10)}
    : ${BG_LIGHTYELLOW:=$(tput setab 11)}
    : ${BG_LIGHTBLUE:=$(tput setab 12)}
    : ${BG_LIGHTMAGENTA:=$(tput setab 13)}
    : ${BG_LIGHTCYAN:=$(tput setab 14)}
    : ${BG_WHITE:=$(tput setab 15)}

    : ${RESET:=$(tput sgr0)}
    : ${BOLD:=$(tput bold)}
    : ${DIM:=$(tput dim)}
    : ${ITALIC:=$(tput sitm)}
    : ${UNDERLINE:=$(tput smul)}
  else
    : ${FG_BLACK:=$'\033[0;30m'}
    : ${FG_RED:=$'\033[0;31m'}
    : ${FG_GREEN:=$'\033[0;32m'}
    : ${FG_YELLOW:=$'\033[0;33m'}
    : ${FG_BLUE:=$'\033[0;34m'}
    : ${FG_MAGENTA:=$'\033[0;35m'}
    : ${FG_CYAN:=$'\033[0;36m'}
    : ${FG_LIGHTGRAY:=$'\033[0;37m'}
    : ${FG_GRAY:=$'\033[1;30m'}
    : ${FG_LIGHTRED:=$'\033[1;31m'}
    : ${FG_LIGHTGREEN:=$'\033[1;32m'}
    : ${FG_LIGHTYELLOW:=$'\033[1;33m'}
    : ${FG_LIGHTBLUE:=$'\033[1;34m'}
    : ${FG_LIGHTMAGENTA:=$'\033[1;35m'}
    : ${FG_LIGHTCYAN:=$'\033[1;36m'}
    : ${FG_WHITE:=$'\033[1;37m'}
    #: ${FG_GRAY:=$'\033[90m'}
    #: ${FG_LIGHTRED:=$'\033[91m'}
    #: ${FG_LIGHTGREEN:=$'\033[92m'}
    #: ${FG_LIGHTYELLOW:=$'\033[93m'}
    #: ${FG_LIGHTBLUE:=$'\033[94m'}
    #: ${FG_LIGHTMAGENTA:=$'\033[95m'}
    #: ${FG_LIGHTCYAN:=$'\033[96m'}
    #: ${FG_WHITE:=$'\033[97m'}

    : ${BG_BLACK:=$'\033[0;40m'}
    : ${BG_RED:=$'\033[0;41m'}
    : ${BG_GREEN:=$'\033[0;42m'}
    : ${BG_YELLOW:=$'\033[0;43m'}
    : ${BG_BLUE:=$'\033[0;44m'}
    : ${BG_MAGENTA:=$'\033[0;45m'}
    : ${BG_CYAN:=$'\033[0;46m'}
    : ${BG_LIGHTGRAY:=$'\033[0;47m'}
    : ${BG_GRAY:=$'\033[1;40m'}
    : ${BG_LIGHTRED:=$'\033[1;41m'}
    : ${BG_LIGHTGREEN:=$'\033[1;42m'}
    : ${BG_LIGHTYELLOW:=$'\033[1;43m'}
    : ${BG_LIGHTBLUE:=$'\033[1;44m'}
    : ${BG_LIGHTMAGENTA:=$'\033[1;45m'}
    : ${BG_LIGHTCYAN:=$'\033[1;46m'}
    : ${BG_WHITE:=$'\033[1;47m'}
    #: ${BG_GRAY:=$'\033[100m'}
    #: ${BG_LIGHTRED:=$'\033[101m'}
    #: ${BG_LIGHTGREEN:=$'\033[102m'}
    #: ${BG_LIGHTYELLOW:=$'\033[103m'}
    #: ${BG_LIGHTBLUE:=$'\033[104m'}
    #: ${BG_LIGHTMAGENTA:=$'\033[105m'}
    #: ${BG_LIGHTCYAN:=$'\033[106m'}
    #: ${BG_WHITE:=$'\033[107m'}

    : ${RESET:=$'\033[0m'}
    : ${BOLD:=$'\033[1m'}
    : ${DIM:=$'\033[2m'}
    : ${ITALIC:=$'\033[3m'}
    : ${UNDERLINE:=$'\033[4m'}
  fi;
else
  : "${FG_BLACK:=}"
  : "${FG_RED:=}"
  : "${FG_GREEN:=}"
  : "${FG_YELLOW:=}"
  : "${FG_BLUE:=}"
  : "${FG_MAGENTA:=}"
  : "${FG_CYAN:=}"
  : "${FG_LIGHTGRAY:=}"
  : "${FG_GRAY:=}"
  : "${FG_LIGHTRED:=}"
  : "${FG_LIGHTGREEN:=}"
  : "${FG_LIGHTYELLOW:=}"
  : "${FG_LIGHTBLUE:=}"
  : "${FG_LIGHTMAGENTA:=}"
  : "${FG_LIGHTCYAN:=}"
  : "${FG_WHITE:=}"

  : "${BG_BLACK:=}"
  : "${BG_RED:=}"
  : "${BG_GREEN:=}"
  : "${BG_YELLOW:=}"
  : "${BG_BLUE:=}"
  : "${BG_MAGENTA:=}"
  : "${BG_CYAN:=}"
  : "${BG_LIGHTGRAY:=}"
  : "${BG_GRAY:=}"
  : "${BG_LIGHTRED:=}"
  : "${BG_LIGHTGREEN:=}"
  : "${BG_LIGHTYELLOW:=}"
  : "${BG_LIGHTBLUE:=}"
  : "${BG_LIGHTMAGENTA:=}"
  : "${BG_LIGHTCYAN:=}"
  : "${BG_WHITE:=}"

  : "${RESET:=}"
  : "${BOLD:=}"
  : "${DIM:=}"
  : "${ITALIC:=}"
  : "${UNDERLINE:=}"
fi
