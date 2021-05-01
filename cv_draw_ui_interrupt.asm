* = $bf08

#define SIMON_X_HIBYTE $41
#define SIMON_X_LOBYTE $40
#define SIMON_Y $3f

NMI
  lda $18
  cmp #$05
  beq start

hereisend
  lda $2002
  jmp interrupt_core+3

start
  ldx #$7c
  ldy #$20

  lda SIMON_X_HIBYTE
  lsr
  lsr
  lsr
  lsr
  and #$0f
#include "cv_drawhexnum.asm"
  inx

  lda SIMON_X_HIBYTE
  and #$0f
#include "cv_drawhexnum.asm"
  inx

  lda SIMON_X_LOBYTE
  lsr
  lsr
  lsr
  lsr
  and #$0f
#include "cv_drawhexnum.asm"
  inx

  lda SIMON_X_LOBYTE
  and #$0f
#include "cv_drawhexnum.asm"

  ldx #$9e
  lda SIMON_Y
; 209C-F
  lsr
  lsr
  lsr
  lsr
  and #$0f
#include "cv_drawhexnum.asm"

  inx
  lda SIMON_Y
  and #$0f
#include "cv_drawhexnum.asm"

  jmp hereisend

interrupt_core = $c058
jmp NMI
