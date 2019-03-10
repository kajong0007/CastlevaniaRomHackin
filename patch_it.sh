#!/bin/bash

set -x
set -e

THIS_DIR=$(dirname $0)
IFILE="$THIS_DIR"/CV1.nes
OFILE="$THIS_DIR"/modified_CV1.nes

### basic program
## CHECK PLAYING
# lda $18            a5 18
# cmp #$05           c9 05
# beq start          f0 06
#end:
# whatever instruction i replace
# ad 02 20
# jump on back 4c 22 c1
#start:
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
# jmp end XXXX (bfb4)

#1C12F,4c,b6,bf
declare -a patch_list
patch_list=$(cat <<EOF
03FBE,a5,18
03FC0,c9,05,f0,06,ad,02,20,4c,22,c1,a9,20,8d,06,20,a9
03FD0,7c,8d,06,20,a9,e5,8d,07,20,a9,20,8d,06,20,a9,7d
03FE0,8d,06,20,a9,dd,8d,07,20,a9,1a,c9,10,30,04,e9,10
03FF0,10,f7,c9,0a,30,06,e9,0a,09,e0,10,02,09,d0,48,a9
04000,20,8d,06,20,a9,7e,8d,06,20,68,8d,07,20,4c,b4,bf
07FBE,a5,18
07FC0,c9,05,f0,06,ad,02,20,4c,22,c1,a9,20,8d,06,20,a9
07FD0,7c,8d,06,20,a9,e5,8d,07,20,a9,20,8d,06,20,a9,7d
07FE0,8d,06,20,a9,dd,8d,07,20,a9,1a,c9,10,30,04,e9,10
07FF0,10,f7,c9,0a,30,06,e9,0a,09,e0,10,02,09,d0,48,a9
08000,20,8d,06,20,a9,7e,8d,06,20,68,8d,07,20,4c,b4,bf
0BFBE,a5,18
0BFC0,c9,05,f0,06,ad,02,20,4c,22,c1,a9,20,8d,06,20,a9
0BFD0,7c,8d,06,20,a9,e5,8d,07,20,a9,20,8d,06,20,a9,7d
0BFE0,8d,06,20,a9,dd,8d,07,20,a9,1a,c9,10,30,04,e9,10
0BFF0,10,f7,c9,0a,30,06,e9,0a,09,e0,10,02,09,d0,48,a9
0C000,20,8d,06,20,a9,7e,8d,06,20,68,8d,07,20,4c,b4,bf
0FFBE,a5,18
0FFC0,c9,05,f0,06,ad,02,20,4c,22,c1,a9,20,8d,06,20,a9
0FFD0,7c,8d,06,20,a9,e5,8d,07,20,a9,20,8d,06,20,a9,7d
0FFE0,8d,06,20,a9,dd,8d,07,20,a9,1a,c9,10,30,04,e9,10
0FFF0,10,f7,c9,0a,30,06,e9,0a,09,e0,10,02,09,d0,48,a9
10000,20,8d,06,20,a9,7e,8d,06,20,68,8d,07,20,4c,b4,bf
13FBE,a5,18
13FC0,c9,05,f0,06,ad,02,20,4c,22,c1,a9,20,8d,06,20,a9
13FD0,7c,8d,06,20,a9,e5,8d,07,20,a9,20,8d,06,20,a9,7d
13FE0,8d,06,20,a9,dd,8d,07,20,a9,1a,c9,10,30,04,e9,10
13FF0,10,f7,c9,0a,30,06,e9,0a,09,e0,10,02,09,d0,48,a9
14000,20,8d,06,20,a9,7e,8d,06,20,68,8d,07,20,4c,b4,bf
17FBE,a5,18
17FC0,c9,05,f0,06,ad,02,20,4c,22,c1,a9,20,8d,06,20,a9
17FD0,7c,8d,06,20,a9,e5,8d,07,20,a9,20,8d,06,20,a9,7d
17FE0,8d,06,20,a9,dd,8d,07,20,a9,1a,c9,10,30,04,e9,10
17FF0,10,f7,c9,0a,30,06,e9,0a,09,e0,10,02,09,d0,48,a9
18000,20,8d,06,20,a9,7e,8d,06,20,68,8d,07,20,4c,b4,bf
1BFBE,a5,18
1BFC0,c9,05,f0,06,ad,02,20,4c,22,c1,a9,20,8d,06,20,a9
1BFD0,7c,8d,06,20,a9,e5,8d,07,20,a9,20,8d,06,20,a9,7d
1BFE0,8d,06,20,a9,dd,8d,07,20,a9,1a,c9,10,30,04,e9,10
1BFF0,10,f7,c9,0a,30,06,e9,0a,09,e0,10,02,09,d0,48,a9
1C000,20,8d,06,20,a9,7e,8d,06,20,68,8d,07,20,4c,b4,bf
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
