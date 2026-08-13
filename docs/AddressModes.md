## Addressing Modes

### Data Register

#### Syntax

```asm
<dreg>
```

#### Description

The operand is stored in an 8-bit data register (`A`, `B`, `C` or `D`).

### Index Register

#### Syntax

```asm
<ireg>
```

#### Description

The operand is stored in an 8-bit index register (`X`, `Y`, `L` or `H`). These
registers may also participate in address formation.

### Register Pair

#### Syntax

```asm
<r16>
```

#### Description

The operand is stored in a 16-bit register pair (`Z` or `SP`).

### System Register

#### Syntax

```asm
<r8>
```

#### Description

The operand is stored in a 8-bit system register (`SR` or `VBR`)

### Implied

#### Syntax

```asm
<instruction>
```

or

```asm
<instruction> #n
```

#### Description

The operand is fully encoded in the opcode. No additional operand bytes are
fetched. Some instructions have no operand at all, while others encode small
immediate value directly within the opcode.

### Immediate

#### Syntax

```asm
#imm8

or

#imm16
```

#### Description

The operand is encoded in the byte/word immediately following the opcode.

### Relative

#### Syntax

```asm
rel8

or

rel16
```

#### Description

The operand is encoded in the byte/word immediately following the opcode. The
value contained in the operand is encoded as a signed integer.

### Absolute

#### Syntax

```asm
abs16
```

#### Description

The word following the opcode is treated as a 16-bit memory address. The
operand is read from or written to that address.

### Paged Addressing

#### Syntax

```asm
[imm8:<ireg>]

or

imm8:<ireg>
```

#### Description

A 16-bit address is formed by concatenating the immediate high-byte with the
selected index register as the low byte.

```asm
Address = (imm8 << 8) | <ireg>
```

### Register Indirect

#### Syntax

```asm
[<r16>]
```

#### Description

The pair-register contains the complete 16-bit memory address. The operand
is accessed through the address stored in register-pair.

### Register Indirect with Post-Increment

#### Syntax

```asm
[<r16>+]
```

#### Description

The operand is accessed through the address stored in the pair-register. Then
immediately after the memory access, the pair-register is incremented.

### Register Indirect with Pre-Decrement

#### Syntax

```asm
[-<r16>]
```

#### Description

The pair-register is immediately decremented before the memory access. Then the
operand is accessed through the resulting address.

## Operand Encoding

Instructions may be encoded in more than one byte following the opcode. They
may be encoded in one of these formats:

#### Format A - Opcode Only

```
+--------+
| Opcode |
+--------+
```

The opcode completely defines the instruction and its operands. Examples:

```asm
HALT
NOP
TRAP #n3
BIT [<r16>]
MOV <ireg>, VBR
MOV SR, <dreg>
INC <dreg>
MULU <dregx>, <dregy>
DIVS <dregx>, <dregy>
RTS
JMP [<r16>]
```

#### Format B - Opcode + Byte

```
+--------+------+
| Opcode | Byte |
+--------+------+
```

After the opcode byte there is an additional byte as an operand. The
byte operand can encode either an unsigned or a signed integer. Examples:

```asm
BCLR <dreg>, #imm8
BIT <dreg>, #imm8
MOVI <dreg>, #imm8
CMPI <dreg>, #imm8
BRA rel8
Bcc rel8
```

#### Format C - Opcode + Word

```
+--------+----------+-----------+
| Opcode | Low Byte | High Byte |
+--------+----------+-----------+
```

After the opcode byte there is two additional bytes as an operand. The bytes
following the opcode form a 16-bit word, which can encode either an unsigned or
a signed integer. Examples:

```asm
BIT <dreg>, abs16
MOVI <r16>, #imm16
JMP abs16
JSR abs16
BSR rel16
```

#### Format D - Opcode + Extension

```
+--------+-----+
| Opcode | Ext |
+--------+-----+
```

The opcode can be extended to 16-bit, which the extension byte encodes
additional operands and data. Examples:

```asm
EXG <dreg>, <ireg>
MOV <dreg>, <dregy>
MOV <dreg>, [<r16>]
MOV [<r16>+], <dreg>
ADC <dreg>, [-<r16>]
CMP <dreg>, [<r16>]
XOR [<r16>+], <dreg>
```

#### Format E - Opcode + Extension + Byte

```
+--------+-----+------+
| Opcode | Ext | Byte |
+--------+-----+------+
```

After the extended opcode, there is an additional byte as an operand. This
operand encodes an unsigned or signed integer data. Examples:

```asm
MOV <dreg>, [imm8:<ireg>]
MOV [imm8:<ireg>], <dreg>
XOR <dreg>, [imm8:<ireg>]
XOR [imm8:<ireg>], <dreg>
```

#### Format F - Opcode + Extension + Word

```
+--------+-----+----------+-----------+
| Opcode | Ext | Low Byte | High Byte |
+--------+-----+----------+-----------+
```

After the extended opcode, there are two additional bytes as an operand. The
bytes following the extended opcode form a 16-bit word. Examples:

```asm
MOV <dreg>, abs16
MOV abs16, <dreg>
MOV <ireg>, abs16
MOV abs16, <ireg>
AND <dreg>, abs16
CMP abs16, <dreg>
OR  <ireg>, abs16
SUB abs16, <ireg>
```

> NOTE: Addressing modes are independent of instruction encoding. The same
> addressing mode may appear in different instruction formats. For example,
> the `BIT` instruction uses Immediate, Absolute or Indirect addressing modes
> without an extension byte, whereas binary arithmetic and data movement use
> the same addressing mode with an extension byte.

---

> Documentation is licensed under CC BY-SA 4.0. <br>
> See https://creativecommons.org/licenses/by-sa/4.0/
