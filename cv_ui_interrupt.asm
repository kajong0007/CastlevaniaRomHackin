; Main Castlevania 1 UI drawing interrupt

; All of this code (except the last 3 bytes) gets written to a blank
; section of memory in each memory bank that starts at 0xBF08
; so this makes sure that the jump instructions are properly
; lined up

; I used the xa assembler because I'm a Linux nerd, so I rely on a couple of features,
; - C preprocessor-like statements, #define and #include
; - setting the program counter for jmp calculation

; xa says in its documentation
;     The program counter * is considered to be a special kind of label,
;     and can be assigned  to  with  statements such as
;             * = $c000

; so if you need to use another assembler, you'll probably need to
; find an equivalent such as making more labels below and setting them

* = $bf08

; xa supports simple preprocessor type stuff like C, so give these
; some human readable names

; simon's X position is 2 bytes
#define SIMON_X_HIBYTE $41
#define SIMON_X_LOBYTE $40

; simon's Y position is just one byte
#define SIMON_Y $3f
#define TILE_COUNTER $30
#define FRAME_COUNTER $1a

; the code injection we do is during the NMI section of the NES
; ROM code, so this label is very vague. This is the first thing
; we do, check that the game's current mode is in mode 5
NMI
  ; address containing game's current "mode", title screen, post boss countdown,
  ; regular gameplay, etc.
  /* see https://datacrystal.romhacking.net/wiki/Castlevania:RAM_map */
  lda $18

  ; a value of 0x5 is "Playing" according to Data Crystal
  cmp #$05

  ; start of _my_ code, but really we're already started?
  ; anyway, if we aren't in "Playing" mode, I don't want to draw
  ; stuff to the screen, so if we are Playing, branch
  ; if we aren't Playing, go to "hereisend" by just moving forwards
  beq start

; the instructions I took over were a 3-byte LDA instruction because a
; jump is also 3 bytes. This is the ol skool way to hack new instructions
; into a program; find a place to insert a new jump, then do that instruction
; before jumping back. I seem to remember researching a bit to make sure it was
; as spot where basically every register got rewritten, so I didn't have other
; state to worry about restoring.

; I will probably explain this elsewhere in
; more detail, but for now, know that this is where I jump back to original code.
hereisend
  ; this is the instruction I replace in patch.py to jump to this code
  lda $2002

  ; this jumps back to the old address but 3 bytes ahead to skip the jmp instruction
  jmp interrupt_core+3

; begin our subroutine to draw UI elements
start
  ; The UI elements are in PPU memory on the NES, so we'll need to write
  ; to the $2006 address to send over where we want to draw our numbers.
  ; The UI is a flat memory space from like $2020 to $20a0 or something
  ; so we need a $20 constantly but X can change here to move us forward
  ; one tile
  /* see https://wiki.nesdev.com/w/index.php/PPU_registers */
  ldx #$7c
  ldy #$20

  ; A byte (0-255) can be represented by 2 hex characters (0-9a-f).
  ; 0x00 is 0, 0xff is 255
  ; It is also really easy (with practice) to convert from
  ; hex to binary and binary to hex

  ; so first, we need to draw the top 4 bits, sometimes called a "nibble",
  ; of simon's X byte 1

  ; load the high byte into the accumulator
  lda SIMON_X_HIBYTE

  ; right shift 4 times to get the upper nibble of A into the bottom nibble
  ; 0xf8 -> 0x0f
  lsr
  lsr
  lsr
  lsr

; draw that hex num to the screen
#include "cv_drawhexnum.asm"

  ; move 1 x position right in the UI
  inx

  ; now we need to draw the other nibble
  lda SIMON_X_HIBYTE
  and #$0f
#include "cv_drawhexnum.asm"

  ; move right again on the UI
  inx

  ; load up the low byte of the x position
  ; and use logical shift right to get the upper nibble again
  lda SIMON_X_LOBYTE
  lsr
  lsr
  lsr
  lsr
#include "cv_drawhexnum.asm"

  ; again, we move right on the UI
  inx

  ; and now the lower nibble again
  lda SIMON_X_LOBYTE
  and #$0f
  jsr draw_hexnum_thing

  ; move far forwards in the UI flat map to get to the next line
  ; where we'll draw our Y coordinates
  ldx #$9b
  lda FRAME_COUNTER
  and #$0f
  cmp #$0a
  bmi under_ten
  lsr
  lsr
  lsr
  jsr draw_hexnum_thing
  inx
  lda FRAME_COUNTER
  and #$0f
  sbc #$09
  bvc just_draw_it
under_ten:
  lda #$00
  sty $2006
  stx $2006
  sta $2007
  inx
  lda FRAME_COUNTER
  and #$0f
just_draw_it:
  jsr draw_hexnum_thing
  inx
  inx

  lda TILE_COUNTER
  lsr
  lsr
  lsr
  lsr
  jsr draw_hexnum_thing

  inx
  lda TILE_COUNTER
  and #$0f
  jsr draw_hexnum_thing

  ; we're done! redo our LDA instruction and leave our subroutine
  jmp hereisend


draw_hexnum_thing:
#include "cv_drawhexnum.asm"
rts

; this is the address where we inject our new code
; the patching util has to write these 3 bytes of jump instruction
; into the right place

; the address here is an xa extension where you can tell it the label 
; is placed at this instruction pointer location
; notice we jump back to this plus 3, that's just for convenience
interrupt_core = $c058
