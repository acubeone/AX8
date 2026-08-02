## ADC - Add with Carry

### Summary

Adds the source operand with carry to the destination operand and stores the
result in the destination location.

### Operation

```
[dst] <- [dst] + [src] + C
```

### Syntax

```asm
ADCI <dreg>, #imm8
ADCI <ireg>, #imm8

ADC <dreg>, <dreg>
ADC <dreg>, <ireg>
ADC <ireg>, <ireg>
ADC <ireg>, <dreg>

ADC <dreg>, abs16
ADC <ireg>, abs16

ADC abs16, <dreg>
ADC abs16, <ireg>

ADC <dreg>, [imm8:<ireg>]
ADC [imm8:<ireg>], <dreg>

ADC <dreg>, [<r16>]
ADC <dreg>, [<r16>+]
ADC <dreg>, [-<r16>]

ADC [<r16>], <dreg>
ADC [<r16>+], <dreg>
ADC [-<r16>], <dreg>
```

## Condition Codes

|  N  |  V  |  C  |  Z  |
| :-: | :-: | :-: | :-: |
| `*` | `*` | `*` | `*` |

---

## ADD - Add Binary

### Summary

Adds the source operand to the destination operand and stores the result in the
destination location.

### Operation

```
[dst] <- [dst] + [src]
```

### Syntax

```asm
ADDI <dreg>, #imm8
ADDI <ireg>, #imm8

ADD <dreg>, <dreg>
ADD <dreg>, <ireg>
ADD <ireg>, <ireg>
ADD <ireg>, <dreg>

ADD <dreg>, abs16
ADD <ireg>, abs16

ADD abs16, <dreg>
ADD abs16, <ireg>

ADD <dreg>, [imm8:<ireg>]
ADD [imm8:<ireg>], <dreg>

ADD <dreg>, [<r16>]
ADD <dreg>, [<r16>+]
ADD <dreg>, [-<r16>]

ADD [<r16>], <dreg>
ADD [<r16>+], <dreg>
ADD [-<r16>], <dreg>
```

## Condition Codes

|  N  |  V  |  C  |  Z  |
| :-: | :-: | :-: | :-: |
| `*` | `*` | `*` | `*` |

---

> Documentation is licensed under CC BY-SA 4.0. <br>
> see https://creativecommons.org/licenses/by-sa/4.0/
