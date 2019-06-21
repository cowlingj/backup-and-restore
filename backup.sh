#!/bin/bash

# TODO: fix versioning
SCRIPT_VERSION="1.0.0"
[ "$1" = "-v" ] || [ "$1" = "--version" ]  && echo "$0 $SCRIPT_VERSION" &&
  exit 0

SOURCE="$(readlink -f "$BASH_SOURCE")"
. "${SOURCE%/*}/lib.sh"

# TODO: look at major versions not exact version (semver and all)
# contains BACKUP_DIR, FILES_MAP, PAC_LIST,
# USER_LIST, USER_PKGS, and FILES
CONFIG_FILE="$(get_backup_config)"
[ "$?" -ne "0" ] && echo "config file not found" >&2 && exit "-1"
. "$CONFIG_FILE" || exit -1
[ "$(grep -Po '^[0-9]+' <<< "$CONFIG_VERSION")" != \
  "$(grep -Po '^[0-9]+' <<< "$SCRIPT_VERSION")" ] &&
  echo "script and config versions aren't compatable" &&
  echo "script version $SCRIPT_VERSION config version $CONFIG_VERSION" &&
  exit "-1"

$(${USE_COMPRESSION})
COMPRESS="$?"

COLORFUL_LOADING="false"
[ "$(tput colors)" -gt "8" ] && COLORFUL_LOADING="true"

# check for a valid backup directory
[ -f "$BACKUP_DIR" ] && echo "backup directory is a file" \
  && exit 1
[ ! -d "$BACKUP_DIR" ]\
  && echo "backup directory doesn't exist, creating"\
  && mkdir "$BACKUP_DIR"
[ "$(ls -A ${BACKUP_DIR})" ] && echo "backup is not empty,"\
  "carrying on anyway"

# make a list file of packman packages
case "$MANAGER" in
  "pacaur") ;&
  "pacman") 
    echo "copying the list of $MANAGER packages"
    $MANAGER -Qqe > "${BACKUP_DIR}/${MANAGED_PKGS}"
    echo "done"
    ;;
  "apt")
    dpkg --get-selections > "${MANAGED_PKGS}"
    cp -R "/etc/apt/sources.list*" "${APT_SOURCES}"
    apt-key exportall > "${APT_KEYS}"
    ;;
esac

# make a list file of user maintained packages
if [ -n "$USER_PKGS" ]; then
  echo "copying the list of user packages"
  n="${#USER_PKGS[@]}"
  i="0"
  for pkg in "${USER_PKGS[@]}"; do
    echo "$pkg" > "${BACKUP_DIR}/${USER_LIST}"
    
    # TODO: make all bars equal
    loading_bar "$i" "$n" "20" "$pkg" "$COLORFUL_LOADING"
    ((i++))
  done
  loading_bar "$i" "$n" "20" "" "$COLORFUL_LOADING"
  echo ""
  echo "done"
fi

# copy files and note down the map
i="0"
n="${#FILES[@]}"
[ "$n" = "0" ] && echo "no files to copy, finished" && exit 0 
echo "copying files (this may take some time)..."
for key in "${!FILES[@]}"; do
  loading_bar "$i" "$n" "40" "copying ${FILES[$key]}" "$COLORFUL_LOADING"
  
  cp -r -T "${FILES[$key]}" "${BACKUP_DIR}/${key}"
  echo -e "${key}\t${FILES[$key]}" >> "${BACKUP_DIR}/${FILES_MAP}"

  ((i++))
done
loading_bar "$i" "$n" "40" "" "$COLORFUL_LOADING"
echo ""
echo "done"

# TODO: REMOVE compression, unless done as a stream, compression should be done by the user
# compress if we should
if [ "${COMPRESS}" -eq "0" ]; then
  echo "compressing"
  tar -cvaf "${COMPRESSED_FILE}" "${BACKUP_DIR}"
  echo "done" && echo "cleaning up"
  rm -r "${BACKUP_DIR}"
  echo "done"
fi

