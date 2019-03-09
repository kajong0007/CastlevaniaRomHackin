#!/bin/bash

set -x
set -e

THIS_DIR=$(dirname $0)

declare -a patch_list
patch_list=$(cat <<EOF
1FF,65
2FF,65,33
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
