#!/bin/bash

set -x
set -e

THIS_DIR=$(dirname $0)

IFILE="$THIS_DIR"/CV1.nes
OFILE="$THIS_DIR"/modified_CV1.nes

ASMFILE=("$THIS_DIR"/cv_nmi.asm "$THIS_DIR"/cv_busyloop.asm)
OUTASM=("$THIS_DIR"/outnmi.a65 "$THIS_DIR"/outbusyloop.a65)
# size is +6 because of 1 extra byte, 1 extra jump, and 1 because i don't
# remember the <= bash operator so i just added 1 and used less than
MAXSIZE=(104 77)
NUMASM=${#ASMFILE[*]}

NMIOUT="${OUTASM[0]}"
BUSYOUT="${OUTASM[1]}"

NMISIZE=0
BUSYSIZE=0

ASSEM="xa"

i=0

while [ $i -lt "$NUMASM" ]
do
  "$ASSEM" "${ASMFILE[$i]}" -o "${OUTASM[$i]}"
  if [ "${MAXSIZE[$i]}" -lt $(stat -c"%s" "${OUTASM[$i]}") ]
  then
    echo "ERROR: File ${ASMFILE[$i]} exceeded max size ${MAXSIZE[$i]}"
    exit 1
  fi
  ((++i))
done

NMISIZE=$(stat -c'%s' "$NMIOUT")
NMIREALSIZE=$(( $NMISIZE - 3 ))

BUSYSIZE=$(stat -c'%s' "$BUSYOUT")
BUSYREALSIZE=$(( $BUSYSIZE - 3 ))

#bf08
#bf6c
nmi_start_addr=$(echo '16i3F18p' | dc)
nmi_end_addr=$(echo '16i1BF19p' | dc)
busy_start_addr=$(echo '16i3F7Cp' | dc)
busy_end_addr=$(echo '16i1BF7Dp' | dc)
step=$(echo '16i4000p' | dc)


#-1C068,4c,ad,bf
#-1C04C,4c,eb,bf

cp "$IFILE" "$OFILE"

i=$nmi_start_addr
j=$busy_start_addr
while [ $i -lt $nmi_end_addr ]
do
  dd conv=notrunc if="$NMIOUT" bs=1 count=$NMIREALSIZE seek=$i of="$OFILE"
  #dd conv=notrunc if="$BUSYOUT" bs=1 count=$BUSYREALSIZE seek=$j of="$OFILE"
  i=$(( $i + $step ))
  j=$(( $j + $step ))
done

dd conv=notrunc if="$NMIOUT" bs=1 count=3 skip=$NMIREALSIZE seek=$(echo '16i1C068p' | dc) of="$OFILE"
#dd conv=notrunc if="$BUSYOUT" bs=1 count=3 skip=$BUSYREALSIZE seek=$(echo '16i1C04Cp' | dc) of="$OFILE"

#echo "$patch_list" | while read line
#do
#  byte_offset=$(echo "16i$(echo "$line" | cut -d',' -f1)p" | dc)
#  bytes=$(echo ","$(echo "$line" | cut -d',' -f2-) | sed -e 's/,/\\x/g')
#  echo -ne "$bytes" | dd conv=notrunc of="$OFILE" ibs=1 obs=1 seek=$byte_offset >/dev/null 2>&1
#done
