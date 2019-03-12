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
  cmp #$0a
  bmi below9
  sbc #$0a
  ora #$e0
  bmi number
below9
  ora #$d0
number
  jsr drawsr

;; Restore X and Y
;  pla
;  tay
;  pla
;  tax
;  bvc hereisend
  jmp hereisend

interrupt_core = $c058
jmp NMI
