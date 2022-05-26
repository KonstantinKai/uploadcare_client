#!/usr/bin/env bash

FILES=('uploadcare_server_mock/assets/base.jpeg' 'uploadcare_server_mock/assets/multipart.mp4')
SIZES=('1m' '20m')

EXECUTABLE=`which mkfile`

if [ ! -f "$EXECUTABLE" ];then
  EXECUTABLE=`which truncate`
  if [ ! -f "$EXECUTABLE" ];then
    echo "Cannot generate bin files on this platform"
    exit 1
    else
    EXECUTABLE="$EXECUTABLE -t"
  fi
fi

for i in "${!FILES[@]}"; do
  if [ ! -f "${FILES[$i]}" ];then
    $EXECUTABLE ${SIZES[$i]} ${FILES[$i]}
    echo "${FILES[$i]} created"
  fi
done

echo ""
