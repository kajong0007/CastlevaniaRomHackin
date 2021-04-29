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

drawsr
  sty $2006
  stx $2006
  sta $2007
  rts

drawhexnum
  cmp #$0a
  bmi below9
  sbc #$0a
  ora #$e0
  bmi number
below9
  ora #$d0
number
  jsr drawsr
  rts

start
  ldx #$7a
  ldy #$20

; draw 'X'
  lda #$f7
  jsr drawsr
  inx

; draw '-'
  lda #$dd
  jsr drawsr
  inx

  lda SIMON_X_HIBYTE
  lsr
  lsr
  lsr
  lsr
  and #$0f
  jsr drawhexnum
  inx

  lda SIMON_X_HIBYTE
  and #$0f
  jsr drawhexnum

  lda SIMON_X_LOBYTE
  lsr
  lsr
  lsr
  lsr
  and #$0f
  jsr drawhexnum
  inx

  lda SIMON_X_LOBYTE
  and #$0f
  jsr drawhexnum

  ldx #$9c
; draw letter 'Y'
  lda #$f8
  jsr drawsr
  inx

  lda #$dd
  jsr drawsr
  inx

  lda SIMON_Y
; 209C-F
  lsr
  lsr
  lsr
  lsr
  and #$0f
  jsr drawhexnum

  inx
  lda SIMON_Y
  and #$0f
  jsr drawhexnum

  jmp hereisend

interrupt_core = $c058
jmp NMI
