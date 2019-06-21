#!/usr/bin/env bash

# loading_spinner.sh

STATE=""
TICK="$1"
[ -z "$1" ] && TICK="0"

case "$(expr "$TICK" "%" "4")" in
  "0") STATE='|';;
  "1") STATE='/';;
  "2") STATE='-';;
  "3") STATE='\\';;
esac

echo -ne "\r$2$STATE\e[0K"

exit "$TICK"
