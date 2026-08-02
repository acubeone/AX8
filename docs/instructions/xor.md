## XOR - Logical XOR

### Summary

Performs logical operation `XOR` at the source with the destination, then
stores the result in destination.

### Operation

```
[dst] <- [dst] ^ [src]
```

### Syntax

```asm
XORI <dreg>, #imm8
XORI <ireg>, #imm8

XOR <dreg>, <dreg>
XOR <dreg>, <ireg>
XOR <ireg>, <ireg>
XOR <ireg>, <dreg>

XOR <dreg>, abs16
XOR <ireg>, abs16

XOR abs16, <dreg>
XOR abs16, <ireg>

XOR <dreg>, [imm8:<ireg>]
XOR [imm8:<ireg>], <dreg>

XOR <dreg>, [<r16>]
XOR <dreg>, [<r16>+]
XOR <dreg>, [-<r16>]

XOR [<r16>], <dreg>
XOR [<r16>+], <dreg>
XOR [-<r16>], <dreg>
```

## Condition Codes

|  N  |  V  |  C  |  Z  |
| :-: | :-: | :-: | :-: |
| `*` | `0` | `0` | `*` |

---

> Documentation is licensed under CC BY-SA 4.0. <br>
> See https://creativecommons.org/licenses/by-sa/4.0/
