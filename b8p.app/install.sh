#!/bin/sh
# Installs the disk.

NAME="BASIC8 Player"
FILE="BASIC8 Player"

DSK="${FILE}.desktop"

BASEDIR=$(dirname "$0")
cd "$BASEDIR"

touch "${DSK}"
echo "[Desktop Entry]" > "${DSK}"
echo "Encoding=UTF-8" >> "${DSK}"
echo "Version=1.2.3" >> "${DSK}"
echo "Name=${NAME}" >> "${DSK}"
echo "GenericName=${NAME}" >> "${DSK}"
echo "Type=Application" >> "${DSK}"
echo "Categories=Development;Game;" >> "${DSK}"
echo "Comment=BASIC8 Player" >> "${DSK}"
echo "Terminal=false" >> "${DSK}"
echo "Path=${PWD}" >> "${DSK}"
echo "Exec=\"${PWD}/play.sh\"" >> "${DSK}"
echo "Icon=${PWD}/Contents/Resources/icon.png" >> "${DSK}"
echo "" >> "${DSK}"
sudo mv -f "${DSK}" "/usr/share/applications/${FILE}.desktop"

sudo chmod 777 play.sh
sudo ./play.sh
