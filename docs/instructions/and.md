## AND - Logical AND

### Summary

Performs logical operation `AND` at the source with the destination and store
the result in destination location.

### Operation

```
[dst] <- [dst] & [src]
```

### Syntax

```asm
ANDI <dreg>, #imm8
ANDI <ireg>, #imm8

AND <dreg>, <dreg>
AND <dreg>, <ireg>
AND <ireg>, <ireg>
AND <ireg>, <dreg>

AND <dreg>, abs16
AND <ireg>, abs16

AND abs16, <dreg>
AND abs16, <ireg>

AND <dreg>, [imm8:<ireg>]
AND [imm8:<ireg>], <dreg>

AND <dreg>, [<r16>]
AND <dreg>, [<r16>+]
AND <dreg>, [-<r16>]

AND [<r16>], <dreg>
AND [<r16>+], <dreg>
AND [-<r16>], <dreg>
```

## Condition Codes

|  N  |  V  |  C  |  Z  |
| :-: | :-: | :-: | :-: |
| `*` | `0` | `0` | `*` |

---

> Documentation is licensed under CC BY-SA 4.0. <br>
> See https://creativecommons.org/licenses/by-sa/4.0/
