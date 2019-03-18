#!/bin/bash

set -x
set -e

THIS_DIR=$(dirname $0)

IFILE="$THIS_DIR"/CV1.nes
OFILE="$THIS_DIR"/modified_CV1.nes

ASMFILE="$THIS_DIR"/cv_nmi.asm
OUTASM="$THIS_DIR"/outnmi.a65
# size is +6 because of 1 extra byte, 1 extra jump, and 1 because i don't
# remember the <= bash operator so i just added 1 and used less than
MAXSIZE=200

NMISIZE=0

ASSEM="xa"

i=0

"$ASSEM" "$ASMFILE" -o "$OUTASM"
if [ "$MAXSIZE" -lt $(stat -c"%s" "$OUTASM") ]
then
  echo "ERROR: File $ASMFILE exceeded max size $MAXSIZE"
  exit 1
fi

NMISIZE=$(stat -c'%s' "$OUTASM")
NMIREALSIZE=$(( $NMISIZE - 3 ))

#bf08
nmi_start_addr=$(echo '16i3F18p' | dc)
nmi_end_addr=$(echo '16i1BF19p' | dc)
step=$(echo '16i4000p' | dc)

#-1C068,4c,ad,bf

cp "$IFILE" "$OFILE"

i=$nmi_start_addr
while [ $i -lt $nmi_end_addr ]
do
  dd conv=notrunc if="$OUTASM" bs=1 count=$NMIREALSIZE seek=$i of="$OFILE"
  i=$(( $i + $step ))
done

dd conv=notrunc if="$OUTASM" bs=1 count=3 skip=$NMIREALSIZE seek=$(echo '16i1C068p' | dc) of="$OFILE"

