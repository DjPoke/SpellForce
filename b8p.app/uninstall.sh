#!/bin/sh
# Uninstalls the disk.

FILE="BASIC8 Player"

DSK="/usr/share/applications/${FILE}.desktop"
if [ -f "${DSK}" ]; then
  sudo rm "${DSK}"
  exit 0
fi

DSK="~/.local/share/applications/${FILE}.desktop"
if [ -f "${DSK}" ]; then
  sudo rm "${DSK}"
  exit 0
fi
