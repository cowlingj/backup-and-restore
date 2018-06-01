#!/usr/bin/env bash

LIB="lib/"

function get_backup_config {
  local FILE_NAME="backup.conf"
  local PATHS=("$HOME/.config/$FILE_NAME" \
    "/usr/local/backup-and-restore/$FILE_NAME" \
    "/etc/backup-and-restore/$FILE_NAME" \
    "config/$FILE_NAME")
  "${LIB}print_first_existing_file.sh" "${PATHS[@]}"
}

function get_restore_config {
  local FILE_NAME="restore.conf"
  local PATHS=("$HOME/.config/$FILE_NAME" \
    "/usr/local/backup-and-restore/$FILE_NAME" \
    "/etc/backup-and-restore/$FILE_NAME" \
    "config/$FILE_NAME") 
  "${LIB}print_first_existing_file.sh" "${PATHS[@]}"
}

function loading_bar {
  "${LIB}loading_bar.sh" "$@"
}
