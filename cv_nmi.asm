NMI = $bf08
  lda $18
  cmp #$05
  beq start
hereisend:
  lda $2002
  jmp interrupt_core+3
start:
;; Save off X and Y
  txa
  pha
  tya
  pha

  ldx #$7c
  ldy #$20

  sty $2006
  stx $2006
  inx
  lda #$e5
  sta $2007

  sty $2006
  stx $2006
  inx
  lda #$dd
  sta $2007

  sty $2006
  stx $2006
  lda $56
  sta $2007

;; Restore X and Y
  pla
  tay
  pla
  tax
  bvc hereisend

interrupt_core = $c058
jmp NMI
