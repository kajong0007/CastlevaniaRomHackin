; special to xa: a "block begin" meta-instruction
; this means that I can have labels that only exist between these parens
.(
  ; digits are in a different sprite memory area than letters, so to draw hex
  ; we need to distinguish the numbers from 0-9 from the letters from a-f
  cmp #$0a

  ; branch on minus tells us the number in register A is below 9
  bmi below9

  ; otherwise, we need to subtract from a-f to below 0-9
  sbc #$0a

  ; all the letters in Castlevania's sprites start at e0 == A and e1 == B, so this
  ; is an easy way to convert a number from 0-9 to a letter
  ora #$e0

  ; 6502 branch instructions are faster than jump instructions by 1 whole cycle,
  ; so apparently branch on minus works here too? I don't actually remember writing
  ; this or how I found this out
  bmi number

; another xa trick: - in front of a label means "I can redefine this all I want"
; so I won't get an assembler error if I make this label many many times
-below9

; the numeric digits 0-9 are at d0 == 0 and d1 == 1 d2 == 2, etc. in the sprite table
  ora #$d0

; here's were we actually draw the sprite in A at the coords in X and Y
; in draw_sr
-number

  ; $2006 is a special double-write register that controls the X,Y coords on screen
  ; to draw the next thing written into $2007
  ; I'm only slightly sure that I kept X and Y consistent with, you know, the usual
  ; coordinate system
  sty $2006
  stx $2006

  ; finally, put our hex digit on screen
  sta $2007
.)
