## SBC - Subtracty with Carry

### Summary

Subtract source operand with borrow from destination operand and store the
result in the destination location.

### Operation

```
[dst] <- [dst] - [src] - (1 - C)
```

### Syntax

```asm
SBCI <dreg>, #imm8
SBCI <ireg>, #imm8

SBC <dreg>, <dreg>
SBC <dreg>, <ireg>
SBC <ireg>, <ireg>
SBC <ireg>, <dreg>

SBC <dreg>, abs16
SBC <ireg>, abs16

SBC abs16, <dreg>
SBC abs16, <ireg>

SBC <dreg>, [imm8:<ireg>]
SBC [imm8:<ireg>], <dreg>

SBC <dreg>, [<r16>]
SBC <dreg>, [<r16>+]
SBC <dreg>, [-<r16>]

SBC [<r16>], <dreg>
SBC [<r16>+], <dreg>
SBC [-<r16>], <dreg>
```

## Condition Codes

|  N  |  V  |  C  |  Z  |
| :-: | :-: | :-: | :-: |
| `*` | `*` | `*` | `*` |

---

## SUB - Subtract Binary

### Summary

Subtract source operand (without borrow) from destination operand and store the
result in destination location.

### Operation

```
[dst] <- [dst] - [src]
```

### Syntax

```asm
SUBI <dreg>, #imm8
SUBI <ireg>, #imm8

SUB <dreg>, <dreg>
SUB <dreg>, <ireg>
SUB <ireg>, <ireg>
SUB <ireg>, <dreg>

SUB <dreg>, abs16
SUB <ireg>, abs16

SUB abs16, <dreg>
SUB abs16, <ireg>

SUB <dreg>, [imm8:<ireg>]
SUB [imm8:<ireg>], <dreg>

SUB <dreg>, [<r16>]
SUB <dreg>, [<r16>+]
SUB <dreg>, [-<r16>]

SUB [<r16>], <dreg>
SUB [<r16>+], <dreg>
SUB [-<r16>], <dreg>
```

## Condition Codes

|  N  |  V  |  C  |  Z  |
| :-: | :-: | :-: | :-: |
| `*` | `*` | `*` | `*` |

---

> Documentation is licensed under CC BY-SA 4.0. <br>
> See https://creativecommons.org/licenses/by-sa/4.0/
