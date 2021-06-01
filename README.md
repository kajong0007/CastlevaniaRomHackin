# NES Rom Patcher with Limited Customizability

# NOTE Documentation is still in-progress

## Why did you make this?

Hello! I'm Jack, and I made this tool to patch specifically Castlevania PRG 1
with some new UI elements (originally the Frame Counter and true RNG, then X
and Y coords), so it was pretty limited in scope, but these techniques can be
generalized to other games and other romhacks.

## How do I use this?

### Things you'll need

* the `xa` assembler is easiest. I was able to install it from repos on
Ubuntu but here's the
[official page](https://www.floodgap.com/retrotech/xa/)
and I found what appears to be a
[Windows build](https://kh-labs.org/concepts/xa65/)
.

Alternatively, you'll need to adjust the code in the
asm files to work with another assembler (explanation in comments of
`cv_draw_ui_interrupt.asm`)

* python 3.1 or higher to run `patch.py`

* a copy of Castlevania 1 for the NES specifically the (U) (PRG 1) version
with an md5 sum and sha256 sum of

```
md5     52eb3f7e2c5fc765aa71f21c85f0770e
sha256  c71be6ac16e8eea7f867cd5437afd1449bef7c4834ec4ca273cafe2882ebfc46
```

### How do I actually patch my ROM?

These instructions are on Linux, but python works on Windows or Linux. I also have
a link to the assembler I used on Linux as well as a link to (supposedly) a Windows
build of that assembler.

Anyway, it's relatively simple: just run `patch.py`

Here's an example:

```
 $ ls -1 *.nes
 CV1.nes
 $ ./patch.py -i CV1.nes -o patched_CV1.nes -A cv_ui_interrupt.asm
 $ ls -1 *.nes
 CV1.nes
 patched_CV1.nes
```

There are other options if you run `patch.py --help` such as
`-a <name of assembler>` that Windows users might have to use to pick up
`xa.exe` or something.

Lots of values for this specific patch are hardcoded into the `patch.py` script,
so it is currently not generalized to other NES games.

From here, I used
[Lipx](https://github.com/kylon/Lipx)
to generate the IPS
patch file, but you can use any patch creation utility.

## How did you make this?

Determination.

### Resources I used

[Nesdev Wiki](https://wiki.nesdev.com/w/index.php/Nesdev_Wiki)

[Data crystal](https://datacrystal.romhacking.net/wiki/Castlevania)
specifically the RAM map and ROM map on the top right

[6502 instruction set](https://www.masswerk.at/6502/6502_instruction_set.html)

[another 6502 page](http://6502.org/tutorials/6502opcodes.html)
that is more explanatory

[6502 in-browser tools](https://skilldrick.github.io/easy6502/)
with an assembler and register display. Great for testing small programs.

### Some NES Information

I knew nothing about the NES when starting on this project. I still know very
little, but I know exactly enough to do all this, so that's cool.

The NES has 2 processors: a 6502 central processing unit (CPU), and a picture
processing unit (PPU). The CPU handles updates to player position and such
and the PPU draws everything to the screen.

I've only looked at 2 games in my debugging emulator: Castlevania and Tetris.
Both of these games have a similar construct in them called a "busy loop".
The NES is drawing to the screen almost every moment of time, but there's a
blanking interval of Cathod Ray Tube (CRT) televisions where the electron
beam is turned off and travelling back up the screen. This is when the NES
does all of its picture drawing logic during what's called the
Non Maskable Interrupt (NMI). At this point in execution, the NES processor
instruction pointer jumps from wherever it is to the NMI address at 0xfffa
and 0xfffb. In Castlevania, this is 0xc052, or as it is in memory:

```
fffa: 52
fffb: c0
```

What we need to do to patch in our game code is two things:

1. Find some unused memory where we can write a bunch of new code

1. Add a new jump instruction that jumps into our code and where we can later jump back

### Finding unused memory

Turns out, this is pretty hard. NES games have a bunch of different segments
to their memory called "banks".
[Data Crystal](https://datacrystal.romhacking.net/wiki/Castlevania)
says that
Castlevania has 8 16kB banks in its ROM, so there are 2 ways we can go about
this business: 1) find out which ROM banks are in use at which parts of the
game and modify those appropriately or 2) find one common location in each
ROM bank and write the code there.

I chose the second option because at least for Castlevania it proved
relatively easy. There's a lot of extra space in each of ROM banks and I was
able to find one address that I could jump to. If you wanted to do something
more exciting, you'll probably need one address common to each of them and
then each of the banks will have a jump instruction there to jump to your
*real* payload, but just get creative.

Data Crystal's
[ROM map](https://datacrystal.romhacking.net/wiki/Castlevania:ROM_map)
has a lot of information, but you'll probably need to explore memory yourself
in your favorite debugging emulator. I used
[Mednafen](https://mednafen.github.io/)
which has some pretty advanced debugging features that I have yet to explore
fully. All screenshots below will be from Mednafen. It's also cross platform,
so hopefully anyone can use it. (at least Windows and Linux users)

### Writing code

I started out hand coding 6502 machine code byte by byte. It kinda sucks. I
would not suggest it. If you want to, I used `xxd`, the hex editor that comes
with `vim`. I really wouldn't suggest it, but I guess it's a "fun" exercise
for some definitions of "fun".

Anyway, the much more reasonable approach to writing 6502 code is using an
assembler. I chose `xa` because it was available for my Ubuntu Linux machine
in the
[main repository](https://packages.ubuntu.com/bionic/xa65)
which surprises me because I didn't think 6502s assemblers were popular
enough to make it into the main repo.

The assembly I need to write here is all relatively simple: grab a memory
value, transform it a little, write stuff somewhere else. Unfortunately, this
does mean learning a whole lot about the NES.

Long story short, I have a lot of documentation in my asm code, but here's
some interesting stuff.

Firstly the 6502 only has 3 registers: A, X, and Y. Most instructions only
operate on A and there are instructions to store A in memory, move A to X,
store stuff at the address in Y, etc. Explore some of the instruction set
at the 6502 links above, but it's all incredibly limited things, so simple
things can be kinda difficult.

```
  sty $2006
  stx $2006

  sta $2007
```
I need a two-byte address onto the screen's memory to be written to $2006,
but each register on the 6502 is one byte. Luckily, I have 3 registers, so I
chose to use X and Y to keep the two bytes of the UI location, and A kept the
value of the tile we wanted to display.

### Code Injection

So how do we get into our code we just wrote? Well, in my case, I was able to
find unused memory at the same bank mapping. This means that I only need one
address to jump to. So, what does that mean?

The `jmp` instruction takes 3 bytes, so we have to find a place we can safely
jump into our routine. There's an `lda $2002` instruction at address 0xc058
and from some code observation, that's all we need to do there. The last thing
we need to do in our injected routine is redo that `lda` followed by jumping
back to the code we previously lept from, 0xc058 + 3 more bytes.

What do I mean by "that's all we need to do there"? Well, we're operating in
assembly, so we don't have things like function calls and "safety". If you
have instructions that change contents of registers, there's no restore
function for you to get an old value back. You have to write that. The
convenience of the location I chose in castlevania, that `lda` instruction,
is that there is code that dumps the current values of A, X, and Y into
RAM right before that `lda` because this is the first step of the non-maskable
interrupt.

When the non-maskable interrupt starts executing the graphics code, it is an
interrupt, so we lept to this code in the middle of an instruction. If we want
that code to operate as expected, we need to restore things to the way they
were when we left, and so there is code written by the Castlevania programmers
to do just that.

That makes it really easy to know that this code is safe for us to inject our
new routine.

### Debugging Castlevania





