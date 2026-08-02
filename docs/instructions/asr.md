## ASR - Arithmetic Shift Right

### Summary

Performs an arithmetic shift right on destination operand and store the result
in destination location.

The effect of an arithmetic shift right is to shift the least-significant bit
into the `C` flag, while the most-significant bit is replicated to preserve the
sign of the integer.

Example:

```asm
MOVI A, #%1011_0010 ; Load value into register A
ASR A               ; The result in A is %1101_1001, and carry is 0
```

### Operation

```
[dst] <- [dst] >> 1
```

### Syntax

```asm
ASR <dreg>
```

### Condition Codes

|  N  |  V  |  C  |  Z  |
| :-: | :-: | :-: | :-: |
| `*` | `0` | `*` | `*` |

### Notes

- There are no `ASL` instruction, since its operation would be identical to
  the `LSL`.

---

> Documentation is licensed under CC BY-SA 4.0. <br>
> See https://creativecommons.org/licenses/by-sa/4.0/
