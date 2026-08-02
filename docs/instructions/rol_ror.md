## ROL/ROR - Rotate Left/Right

### Summary

Performs a bit rotation on destination operand and store the result in the
destination location. This is a circular operation, in the sense that the bit
shifted out at one end is shifted into the other end. So no bit is lost or
destroyed in the operation.

Example:

```asm
MOVI A, #%1011_0010 ; Load value into register A. And carry is 1
ROL A               ; The result in A is %0110_0101, and carry is 1

MOVI A, #%1011_00
ROR A               ; The result in A is %1101_1001, and carry is 0
```

### Operation

```
ROL
  [dst] <- C < [dst] < C
ROR
  [dst] <- C > [dst] > C
```

### Syntax

```asm
ROL <dreg>

ROR <dreg>
```

### Condition Code

|  N  |  V  |  C  |  Z  |
| :-: | :-: | :-: | :-: |
| `*` | `0` | `*` | `*` |

---

> Documentation is licensed under CC BY-SA 4.0. <br>
> See https://creativecommons.org/licenses/by-sa/4.0/
