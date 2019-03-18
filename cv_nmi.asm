* = $bf08
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
  ldx #$7c
  ldy #$20

  lda #$e5
  jsr drawsr
  inx

  lda #$dd
  jsr drawsr
  inx

  lda $1a
  and #$0f
  jsr drawhexnum

  ldx #$9c
  lda #$f1
  jsr drawsr
  inx

  lda #$dd
  jsr drawsr
  inx

  lda $6f
; 209C-F
  lsr
  lsr
  lsr
  lsr
  and #$0f
  jsr drawhexnum

  inx
  lda $6f
  and #$0f
  jsr drawhexnum

  jmp hereisend

interrupt_core = $c058
jmp NMI
