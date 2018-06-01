#!/usr/bin/env bash

for f in "$@"; do
  if [ -f "$f" ]; then
    echo "$f"
    exit 0
  fi
done
exit 1

