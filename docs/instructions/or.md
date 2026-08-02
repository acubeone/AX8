## OR - Logical OR

### Summary

Performs logical operation `OR` at the source with the destination, then
stores the result in destination.

### Operation

```
[dst] <- [dst] | [src]
```

### Syntax

```asm
ORI <dreg>, #imm8
ORI <ireg>, #imm8

OR <dreg>, <dreg>
OR <dreg>, <ireg>
OR <ireg>, <ireg>
OR <ireg>, <dreg>

OR <dreg>, abs16
OR <ireg>, abs16

OR abs16, <dreg>
OR abs16, <ireg>

OR <dreg>, [imm8:<ireg>]
OR [imm8:<ireg>], <dreg>

OR <dreg>, [<r16>]
OR <dreg>, [<r16>+]
OR <dreg>, [-<r16>]

OR [<r16>], <dreg>
OR [<r16>+], <dreg>
OR [-<r16>], <dreg>
```

## Condition Codes

|  N  |  V  |  C  |  Z  |
| :-: | :-: | :-: | :-: |
| `*` | `0` | `0` | `*` |

---

> Documentation is licensed under CC BY-SA 4.0. <br>
> See https://creativecommons.org/licenses/by-sa/4.0/
