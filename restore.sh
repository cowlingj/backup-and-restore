#!/bin/bash

SCRIPT_VERSION="1.0.0"
[ "$1" = "-v" ] || [ "$1" = "--version" ]  && echo "$0 $SCRIPT_VERSION" &&
  exit 0

SOURCE="$(readlink -f "$BASH_SOURCE")"
. "${SOURCE%/*}/lib.sh"

# contains BACKUP_DIR, FILES_MAP, PAC_LIST,
# USER_LIST, USER_PKGS, and FILES
CONFIG_FILE="$(get_restore_config)"
[ "$?" -ne "0" ] && echo "config file not found" >&2 && exit "-1"
. "$CONFIG_FILE" || exit -1
[ "$(grep -Po '^[0-9]+' <<< "$CONFIG_VERSION")" != \
  "$(grep -Po '^[0-9]+' <<< "$SCRIPT_VERSION")" ] &&
  echo "script and config versions aren't compatable" &&
  echo "script version $SCRIPT_VERSION config version $CONFIG_VERSION" &&
  exit "-1"

$(${USE_COMPRESSION})
COMPRESS="$?"

# extract file if needed
[ "${COMPRESS}" ] &&  echo "extracting"\
  && tar -xvaf "${COMPRESSED_FILE}" "${BACKUP_DIR}" && echo "done"

IFS=$'\t'

i=0
n="$( wc -l < "${BACKUP_DIR}/${FILES_MAP}" )"

[ "$n" = "0" ] && echo "no files specified in ${BACKUP_DIR}/${FILES_MAP}"\
  "nothing to do" && exit 1

echo "restoring backed up files and directories"

while read -r KEY VALUE; do
  loading_bar "$i" "$n" "40"
  echo "/${VALUE}"
  cp "${CP_ARGS[@]}" "${BACKUP_DIR}/${KEY}" "/${VALUE}"
  (( i++ ))
done < "${BACKUP_DIR}/${FILES_MAP}"

loading_bar "$i" "$n" "40"
echo ""
echo "done"

# restore managed packages
if "$RESTORE_PKGS"; then
  case "$MANAGER" in
    "pacaur")
      pacman -Qi pacaur
      if [ "$?" -ne "0" ]; then
        pacman -S pacaur
      fi
      pacaur -S - < "${BACKUP_DIR}/${MANAGED_PKGS}"
      ;;
    "pacman")
      pacman -S - < "${BACKUP_DIR}/${MANAGED_PKGS}"
      ;;
    "apt")
      apt-key add "${BACKUP_DIR}/$APT_KEYS"
      cp -R "${BACKUP_DIR}/$APT_SOURCES*" "/etc/apt/"
      apt-get update
      apt-get install dselect
      dpkg --set-selections < "${MANAGED_PKGS}"
      ;;
    "*") echo "sorry, i don't know how to install $MANAGER packages"
      ;;
  esac
fi

# clean up remnants of decompression
[ "${COMPRESS}" ] && echo "cleaning up" && rm -r "${BACKUP_DIR}"
