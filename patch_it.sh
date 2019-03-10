#!/bin/bash

set -x
set -e

THIS_DIR=$(dirname $0)
IFILE="$THIS_DIR"/CV1.nes
OFILE="$THIS_DIR"/modified_CV1.nes

### basic program
## Draw F
# 2   lda #$20        a9 20
# 3   sta into $2006  8d 06 20
# 2   lda #$7c        a9 7c
# 3   sta into $2006  8d 06 20
# 2   lda #$e5        a9 e5
# 3   sta $2007       8d 07 20

## Draw "-"
# 2   lda #$20        a9 20
# 3   sta into $2006  8d 06 20
# 2   lda #$7d        a9 7d
# 3   sta into $2006  8d 06 20
# 2   lda #$dd        a9 dd
# 3   sta $2007       8d 07 20

## timer % 16
# 2   lda $1a         a9 1a
#preloop:
# 2   cmp #16         c9 10
# 3   bmi postloop(+4)30 04
# 2   sbc #16         e9 10
# 3   bpl preloop (-8)10 f7
# POSTLOOP:
# 2   cmp #10         c9 0a
# 3   bmi below9(+XX) 30 06
# 2   sbc #10         e9 0a
# 2   ora 0xE0        09 e0
# 3   bpl number(+XX) 10 02
#below9:
# 2   ora 0xD0        09 d0
#number:
# 1   pha             48
# 2   lda #20         a9 20
# 3   sta into $2006  8d 06 20
# 2   lda #7e         a9 7e
# 2   sta into $2006  8d 06 20
# 1   pla             68
# 3   sta $2007       8d 07 20

# whatever instruction i replace
# ad 02 20
# jump on back 4c 22 c1

#1C12F,4c,b6,bf
declare -a patch_list
patch_list=$(cat <<EOF
3FC6,a9,20,8d,06,20,a9,7c,8d,06
3FD0,20,a9,e5,8d,07,20,a9,20,8d,06,20,a9,7d,8d,06,20
3FE0,a9,dd,8d,07,20,a9,1a,c9,10,30,04,e9,10,10,f7,c9
3FF0,0a,30,06,e9,0a,09,e0,10,02,09,d0,48,a9,20,8d,06
4000,20,a9,7e,8d,06,20,68,8d,07,20,ad,02,20,4c,22,c1
7FC6,a9,20,8d,06,20,a9,7c,8d,06
7FD0,20,a9,e5,8d,07,20,a9,20,8d,06,20,a9,7d,8d,06,20
7FE0,a9,dd,8d,07,20,a9,1a,c9,10,30,04,e9,10,10,f7,c9
7FF0,0a,30,06,e9,0a,09,e0,10,02,09,d0,48,a9,20,8d,06
8000,20,a9,7e,8d,06,20,68,8d,07,20,ad,02,20,4c,22,c1
BFC6,a9,20,8d,06,20,a9,7c,8d,06
BFD0,20,a9,e5,8d,07,20,a9,20,8d,06,20,a9,7d,8d,06,20
BFE0,a9,dd,8d,07,20,a9,1a,c9,10,30,04,e9,10,10,f7,c9
BFF0,0a,30,06,e9,0a,09,e0,10,02,09,d0,48,a9,20,8d,06
C000,20,a9,7e,8d,06,20,68,8d,07,20,ad,02,20,4c,22,c1
FFC6,a9,20,8d,06,20,a9,7c,8d,06
FFD0,20,a9,e5,8d,07,20,a9,20,8d,06,20,a9,7d,8d,06,20
FFE0,a9,dd,8d,07,20,a9,1a,c9,10,30,04,e9,10,10,f7,c9
FFF0,0a,30,06,e9,0a,09,e0,10,02,09,d0,48,a9,20,8d,06
10000,20,a9,7e,8d,06,20,68,8d,07,20,ad,02,20,4c,22,c1
13FC6,a9,20,8d,06,20,a9,7c,8d,06
13FD0,20,a9,e5,8d,07,20,a9,20,8d,06,20,a9,7d,8d,06,20
13FE0,a9,dd,8d,07,20,a9,1a,c9,10,30,04,e9,10,10,f7,c9
13FF0,0a,30,06,e9,0a,09,e0,10,02,09,d0,48,a9,20,8d,06
14000,20,a9,7e,8d,06,20,68,8d,07,20,ad,02,20,4c,22,c1
17FC6,a9,20,8d,06,20,a9,7c,8d,06
17FD0,20,a9,e5,8d,07,20,a9,20,8d,06,20,a9,7d,8d,06,20
17FE0,a9,dd,8d,07,20,a9,1a,c9,10,30,04,e9,10,10,f7,c9
17FF0,0a,30,06,e9,0a,09,e0,10,02,09,d0,48,a9,20,8d,06
18000,20,a9,7e,8d,06,20,68,8d,07,20,ad,02,20,4c,22,c1
1BFC6,a9,20,8d,06,20,a9,7c,8d,06
1BFD0,20,a9,e5,8d,07,20,a9,20,8d,06,20,a9,7d,8d,06,20
1BFE0,a9,dd,8d,07,20,a9,1a,c9,10,30,04,e9,10,10,f7,c9
1BFF0,0a,30,06,e9,0a,09,e0,10,02,09,d0,48,a9,20,8d,06
1C000,20,a9,7e,8d,06,20,68,8d,07,20,ad,02,20,4c,22,c1
EOF
)

num_patch=${#patch_list}

cp "$IFILE" "$OFILE"
echo "$patch_list" | while read line
do
  byte_offset=$(echo "16i$(echo "$line" | cut -d',' -f1)p" | dc)
  bytes=$(echo ","$(echo "$line" | cut -d',' -f2-) | sed -e 's/,/\\x/g')
  echo -ne "$bytes" | dd conv=notrunc of="$OFILE" ibs=1 obs=1 seek=$byte_offset >/dev/null 2>&1
done
