#!/bin/bash

set -x
set -e

THIS_DIR=$(dirname $0)
IFILE="$THIS_DIR"/CV1.nes
OFILE="$THIS_DIR"/modified_CV1.nes

### basic program
## NMI Section
## check currently playing
# 2 3 lda $18         a5 18
# 2 2 cmp #$05        c9 05
# 2 2 beq start       f0 06
# end:
# 3 4 replaced instr  ad 02 20
# 3 4 jump on back    4c 5b c0
# start:
# 1 2 txa             8a
# 1 2 pha             48
# 1 2 tya             98
# 1 2 pha             48
# 2 3 ldx #$7c        a2 7c
# 2 3 ldy #$20        a0 20
# 3 4 sty into $2006  8c 06 20
# 3 4 stx into $2006  8e 06 20
# 1 2 inx             28
# 2 3 lda #$e5        a9 e5
# 3 4 sta into $2007  8d 07 20
# 3 4 sty into $2006  8c 06 20
# 3 4 stx into $2006  8e 06 20
# 1 2 inx             e8
# 2 3 lda #$dd        a9 dd
# 3 4 sta into $2007  8d 07 20
# 3 4 sty into $2006  8c 06 20
# 3 4 stx into $2006  8e 06 20
# ram value (56)
# 2   lda $XX         a5 56
# 3   sta $2007       8d 07 20
# pla                 68
# tay                 a8
# pla                 68
# tax                 aa
# jump "end"          4c XX XX

## 1a value in ram 56
# 2   lda $1a         a5 1a
# 2   and #0f         29 0f
# 2   cmp #0a         c9 0a
# 3   bmi below9(+XX) 30 06
# 2   sbc #0a         e9 0a
# 2   ora 0xE0        09 e0
# 3   bmi number(+XX) 30 02
#below9:
# 2   ora 0xD0        09 d0
#number:
# 2   sta $56         85 56
# jmp end             4c 3c c0

declare -a patch_list
patch_list=$(cat <<EOF
1C068,4c,ad,bf
1C04C,4c,eb,bf
03FBD,a5,18,c9
03FC0,05,f0,06,ad,02,20,4c,5b,c0,8a,48,98,48,a2,7c,a0
03FD0,20,8c,06,20,8e,06,20,28,a9,e5,8d,07,20,8c,06,20
03FE0,8e,06,20,e8,a9,dd,8d,07,20,8c,06,20,8e,06,20,a5
03FF0,56,8d,07,20,68,a8,68,aa,4c,b3,bf,a5,1a,29,0f,c9
04000,0a,30,06,e9,0a,09,e0,30,02,09,d0,85,56,4c,3c,c0
07FBD,a5,18,c9
07FC0,05,f0,06,ad,02,20,4c,5b,c0,8a,48,98,48,a2,7c,a0
07FD0,20,8c,06,20,8e,06,20,28,a9,e5,8d,07,20,8c,06,20
07FE0,8e,06,20,e8,a9,dd,8d,07,20,8c,06,20,8e,06,20,a5
07FF0,56,8d,07,20,68,a8,68,aa,4c,b3,bf,a5,1a,29,0f,c9
08000,0a,30,06,e9,0a,09,e0,30,02,09,d0,85,56,4c,3c,c0
0BFBD,a5,18,c9
0BFC0,05,f0,06,ad,02,20,4c,5b,c0,8a,48,98,48,a2,7c,a0
0BFD0,20,8c,06,20,8e,06,20,28,a9,e5,8d,07,20,8c,06,20
0BFE0,8e,06,20,e8,a9,dd,8d,07,20,8c,06,20,8e,06,20,a5
0BFF0,56,8d,07,20,68,a8,68,aa,4c,b3,bf,a5,1a,29,0f,c9
0C000,0a,30,06,e9,0a,09,e0,30,02,09,d0,85,56,4c,3c,c0
0FFBD,a5,18,c9
0FFC0,05,f0,06,ad,02,20,4c,5b,c0,8a,48,98,48,a2,7c,a0
0FFD0,20,8c,06,20,8e,06,20,28,a9,e5,8d,07,20,8c,06,20
0FFE0,8e,06,20,e8,a9,dd,8d,07,20,8c,06,20,8e,06,20,a5
0FFF0,56,8d,07,20,68,a8,68,aa,4c,b3,bf,a5,1a,29,0f,c9
10000,0a,30,06,e9,0a,09,e0,30,02,09,d0,85,56,4c,3c,c0
13FBD,a5,18,c9
13FC0,05,f0,06,ad,02,20,4c,5b,c0,8a,48,98,48,a2,7c,a0
13FD0,20,8c,06,20,8e,06,20,28,a9,e5,8d,07,20,8c,06,20
13FE0,8e,06,20,e8,a9,dd,8d,07,20,8c,06,20,8e,06,20,a5
13FF0,56,8d,07,20,68,a8,68,aa,4c,b3,bf,a5,1a,29,0f,c9
14000,0a,30,06,e9,0a,09,e0,30,02,09,d0,85,56,4c,3c,c0
17FBD,a5,18,c9
17FC0,05,f0,06,ad,02,20,4c,5b,c0,8a,48,98,48,a2,7c,a0
17FD0,20,8c,06,20,8e,06,20,28,a9,e5,8d,07,20,8c,06,20
17FE0,8e,06,20,e8,a9,dd,8d,07,20,8c,06,20,8e,06,20,a5
17FF0,56,8d,07,20,68,a8,68,aa,4c,b3,bf,a5,1a,29,0f,c9
18000,0a,30,06,e9,0a,09,e0,30,02,09,d0,85,56,4c,3c,c0
1BFBD,a5,18,c9
1BFC0,05,f0,06,ad,02,20,4c,5b,c0,8a,48,98,48,a2,7c,a0
1BFD0,20,8c,06,20,8e,06,20,28,a9,e5,8d,07,20,8c,06,20
1BFE0,8e,06,20,e8,a9,dd,8d,07,20,8c,06,20,8e,06,20,a5
1BFF0,56,8d,07,20,68,a8,68,aa,4c,b3,bf,a5,1a,29,0f,c9
1C000,0a,30,06,e9,0a,09,e0,30,02,09,d0,85,56,4c,3c,c0
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
