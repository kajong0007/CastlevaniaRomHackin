.(
  cmp #$0a
  bmi below9
  sbc #$0a
  ora #$e0
  bmi number
-below9
  ora #$d0
-number
#include "cv_drawsr.asm"
.)
