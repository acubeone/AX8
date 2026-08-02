## LSL/LSR - Logical Shift Left/Right

### Summary

Performs a logical shift on destination operand and store the result in
destination location. A zero is shifted into the input position and the bit
shifted out is copied into the `C` flag.

Example:

```asm
; Shifting left
MOVI A, #%1011_0010 ; Load value into register A
LSR A               ; The result in A is %0110_0100, and carry is 1

; Shifting right
MOVI A, #%1011_0010 ; Load value into register A
LSR A               ; The result in A is %0101_1001, and carry is 0
```

### Operation

```
LSL
  [dst] <- [dst] << 1
LSR
  [dst] <- [dst] >> 1
```

### Syntax

```
LSL <dreg>

LSR <dreg>
```

### Condition Code

|  N  |  V  |  C  |  Z  |
| :-: | :-: | :-: | :-: |
| `*` | `0` | `*` | `*` |

---

> Documentation is licensed under CC BY-SA 4.0. <br>
> See https://creativecommons.org/licenses/by-sa/4.0/
