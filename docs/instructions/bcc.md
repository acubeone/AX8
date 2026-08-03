## Bcc - Branch if Condition CC

### Summary

Checks provided logical condition, and if logical condition is true, program
execution continues at `PC + rel8`. The value of PC is the current location
plus two, effectivelly being `PC + 2 + rel8`. The `rel8` is interpreted as a
two's complement integer.

| Mnemonic | Description              | Logic |
| :------: | :----------------------- | :---- |
|  `BNE`   | Branch on not equal      | `~Z`  |
|  `BCC`   | Branch on carry clear    | `~C`  |
|  `BVC`   | Branch on overflow clear | `~V`  |
|  `BPL`   | Branch on plus/positive  | `~N`  |
|  `BEQ`   | Branch on equal          | `Z`   |
|  `BCS`   | Branch on carry set      | `C`   |
|  `BVS`   | Branch on overflow set   | `V`   |
|  `BMI`   | Branch on minus/negative | `N`   |

### Operation

```
IF cc=1 THEN
  PC <- PC + 2 + rel8
```

### Syntax

```asm
Bcc rel8
Bcc <label>
```

### Condition Codes

|  N  |  V  |  C  |  Z  |
| :-: | :-: | :-: | :-: |
| `.` | `.` | `.` | `.` |

---

> Documentation is licensed under CC BY-SA 4.0. <br>
> See https://creativecommons.org/licenses/by-sa/4.0/
