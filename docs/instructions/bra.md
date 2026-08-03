## BRA - Branch Always

### Summary

Program execution continues at `PC + rel8`. The value of PC is the current
location plus two, effectivelly being `PC + 2 + rel8`. The `rel8` is
interpreted as a two's complement integer.

### Operation

```
PC <- PC + 2 + rel8
```

### Syntax

```asm
BRA rel8
BRA <label>
```

### Condition Codes

|  N  |  V  |  C  |  Z  |
| :-: | :-: | :-: | :-: |
| `.` | `.` | `.` | `.` |

---

> Documentation is licensed under CC BY-SA 4.0. <br>
> See https://creativecommons.org/licenses/by-sa/4.0/
