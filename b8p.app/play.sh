#!/bin/sh
# Player launcher of BASIC8.

CPU="$(uname -m)"
PROG=b8p

BASEDIR=$(dirname "$0")
cd "$BASEDIR"

case "${CPU}" in
  "x86_64")
    cd "Contents/Resources/x64"
    ;;
  "i686")
    cd "Contents/Resources/x86"
    ;;
  "armv6l"|"armv7l")
    echo "Not supported."
    exit 1
    ;;
esac

F1=$(stat -c "%a" ${PROG} | cut -b 1)
F2=$(stat -c "%a" ${PROG} | cut -b 2)
F3=$(stat -c "%a" ${PROG} | cut -b 3)
if [ ${F1} -ne 7 ] || [ ${F3} -ne 7 ] || [ ${F3} -ne 7 ]; then
  echo "Need execution permission to execute BASIC8 player."
  FF=777
  sudo chmod ${FF} ${PROG}
fi
./${PROG}
