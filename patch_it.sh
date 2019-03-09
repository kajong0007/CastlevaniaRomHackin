#!/bin/bash

set -x
set -e

THIS_DIR=$(dirname $0)

declare -a patch_list
patch_list=$(cat <<EOF
1C12F,4c,e0,c4
1C4F0,ad,1a,00,4c,08,d3
1D318,8d,fd,07,4c,84,d3
1D394,ad,02,20,4c,22,c1
EOF
)

num_patch=${#patch_list}

cp "$THIS_DIR"/CV1.nes "$THIS_DIR"/patched_CV1.nes
echo "$patch_list" | while read line
do
  byte_offset=$(echo "16i$(echo "$line" | cut -d',' -f1)p" | dc)
  bytes=$(echo ","$(echo "$line" | cut -d',' -f2-) | sed -e 's/,/\\x/g')
  echo -ne "$bytes" | dd conv=notrunc of=patched_CV1.nes ibs=1 obs=1 seek=$byte_offset >/dev/null 2>&1
done
