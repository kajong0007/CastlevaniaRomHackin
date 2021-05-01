# NES Rom Patcher with Limited Customizability

## Why did you make this?

Hello! I'm Jack, and I made this tool to patch specifically Castlevania PRG 1
with some new UI elements (originally the Frame Counter and true RNG, then X
and Y coords), so it was pretty limited in scope, but these techniques can be
generalized to other games and other romhacks.

## How do I use this?

### Things you'll need

- the `xa` assembler is easiest. I was able to install it from repos on
Ubuntu but here's the
[https://www.floodgap.com/retrotech/xa/](official page)
and I found what appears to be a
[https://kh-labs.org/concepts/xa65/](Windows build).

Alternatively, you'll need to adjust the code in the
asm files to work with another assembler (explanation in comments of
`cv_draw_ui_interrupt.asm`)

- python 3.1 or higher to run `patch.py`

- a copy of Castlevania 1 for the NES specifically the (U) (PRG 1) version
with an md5 sum and sha256 sum of

```
md5     52eb3f7e2c5fc765aa71f21c85f0770e
sha256  c71be6ac16e8eea7f867cd5437afd1449bef7c4834ec4ca273cafe2882ebfc46
```

### Alright, let me use it thanks

These instructions are on Linux, but python works on Windows or Linux.

## How did you make this?
