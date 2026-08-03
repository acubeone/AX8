## BSR - Branch to Subroutine

### Summary

The address of the next instruction following `BSR` instruction is pushed into
the stack pointed by `SP`. Program execution continues at `PC + rel8`. The
value of PC is the current location plus two, effectivelly being
`PC + 2 + rel8`. The `rel8` is interpreted as a two's complement integer.

### Operation

```
PUSH PCH
PUSH PCL
PC <- PC + 2 + rel8
```

### Syntax

```asm
BSR rel8
BSR <label>
```

### Condition Codes

|  N  |  V  |  C  |  Z  |
| :-: | :-: | :-: | :-: |
| `.` | `.` | `.` | `.` |

---

> Documentation is licensed under CC BY-SA 4.0. <br>
> See https://creativecommons.org/licenses/by-sa/4.0/
