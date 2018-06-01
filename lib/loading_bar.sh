#!/usr/bin/env bash
#######################################################################
# loading_bar - prints a loading bar to stdout                        #
# $1 - progress (i)                                                   #
# $2 - max progress (n)                                               #
# $3 - bar length                                                     #
# $4 - decoration string                                              #
# $5 - use colors                                                     #
#######################################################################

DEFAULT_BAR_LEN="20"

# parse args
I="$1"
[ "$(bc <<< "$I < 0")" -eq "1" ] && I="0"

N="$2"
[ "$(bc <<< "$N < 0")" -eq "1" ] && N="0"

# cap I at N
[ "$(bc <<< "$I > $N")" -eq "1" ] && I="$N"

LEN="$3"
[ -z "$LEN" ] && LEN="$DEFAULT_BAR_LEN"

if [ -n "$5" ] && $5; then
  FULL="\e[42m \e[0m"
  EMPTY="\e[100m \e[0m"
else
  FULL="#"
  EMPTY="-"
fi

# get filled and unfilled parts of the bar seperately
FILLED="$(printf "%$(bc <<< "scale=0; $I * $LEN / $N" )s" "")"
FILLED="${FILLED// /$FULL}"

UNFILLED="$(printf "%$(bc <<< "scale=0; $LEN - ($I * $LEN / $N)" )s" "")"
UNFILLED="${UNFILLED// /$EMPTY}"

# then print them together
echo -ne "\r$4[$FILLED$UNFILLED][$I/$N]\e[0K"

exit 0

