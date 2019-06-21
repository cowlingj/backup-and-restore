#!/usr/bin/env bash

# loading_string.sh

STATE=""
TICK="$1"
[ -z "$1" ] && TICK="0"

LOADING_STRING="$3"
[ -z "$LOADING_STRING" ] && LOADING_STRING='_,.-*"'"'"'"*-.,_,.-*"'"'"'"*-.,_,.-*"'"'"'"*-.,_,.-*"'"'"'"*-.,'

N_SHIFTED="$(expr "$TICK" "%" "${#LOADING_STRING}")"

SHIFTED="${LOADING_STRING:$N_SHIFTED}"
STATIONARY="${LOADING_STRING:0:$N_SHIFTED}"

echo -ne "\r$2$SHIFTED$STATIONARY\e[0K"

exit "0"
