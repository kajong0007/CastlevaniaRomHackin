NMI = $bf08
  lda $18
  cmp #$05
  beq start
end:
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
  bvc end

BUSYLOOP = NMI + 100
  lda $1a
  and #$0f
  cmp #$0a
  bmi below9
  sbc #$0a
  ora #$e0
  bmi number
below9:
  ora #$d0
number:
  sta $56
  jmp busyloop_core+3


interrupt_core = $c058
jmp NMI
busyloop_core = $c03c
jmp BUSYLOOP
