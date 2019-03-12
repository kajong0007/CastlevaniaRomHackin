BUSYLOOP = $bf08 + 100
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
  jmp busyloop_core

busyloop_core = $c030
jmp BUSYLOOP
