## Addressing Modes

### Data Register

#### Syntax

```
<dreg>
```

#### Description

The operand is stored in an 8-bit data register (`A`, `B`, `C` or `D`).

### Index Register

#### Syntax

```
<ireg>
```

#### Description

The operand is stored in an 8-bit index register (`X`, `Y`, `L` or `H`). These
registers may also participate in address formation.

### Register Pair

#### Syntax

```
<r16>
```

#### Description

The operand is stored in a 16-bit register pair (`Z` or `SP`).

### System Register

#### Syntax

```
<r8>
```

#### Description

The operand is stored in a 8-bit system register (`SR` or `VBR`)

### Implied

#### Syntax

```
<instruction>
```

or

```
<instruction> #n
```

#### Description

The operand is fully encoded in the opcode. No additional operand bytes are
fetched. Some instructions have no operand at all, while others encode small
immediate value directly within the opcode.

### Immediate

#### Syntax

```
#imm8

#imm16

rel8
```

#### Description

The operand is encoded in the byte/word immediately following the opcode.

### Absolute

#### Syntax

```
abs16
```

#### Description

The word following the opcode is treated as a 16-bit memory address. The
operand is read from or written to that address.

### Paged Addressing

#### Syntax

```
[imm8:<ireg>]
```

or

```
imm8:<ireg>
```

#### Description

A 16-bit address is formed by concatenating the immediate high-byte with the
selected index register as the low byte.

```
Address = (imm8 << 8) | <ireg>
```

### Register Indirect

#### Syntax

```
[<r16>]
```

#### Description

The pair-register contains the complete 16-bit memory address. The operand
is accessed through the address stored in register-pair.

### Register Indirect with Post-Increment

#### Syntax

```
[<r16>+]
```

#### Description

The operand is accessed through the address stored in the pair-register. Then
immediately after the memory access, the pair-register is incremented.

### Register Indirect with Pre-Decrement

#### Syntax

```
[-<r16>]
```

#### Description

The pair-register is immediately decremented before the memory access. Then the
operand is accessed through the resulting address.

## Operand Encoding

Instructions may be encoded in more than one byte following the opcode. They
may be encoded in one of these encodings:

### Single-byte Encoding

```
+--------+
| Opcode |
+--------+
```

The opcode completely defines the instruction and its operands. This format is
used by:

- Implied instructions
- Single-register instructions
- `JMP Z` and `JSR Z` uses this encoding

No extension or operand bytes follows the opcode.

### Operand Encoding

```
+--------+--------------+
| Opcode | Byte Operand |
+--------+--------------+
```

or

```
+--------+--------------+--------------+
| Opcode | Byte Operand | Byte Operand |
+--------+--------------+--------------+
```

Following the opcode there may be operand bytes which specifies operand data or
address. This format is used by:

- Branch and Jump instructions
- The `BIT` instruction

### Extended Encoding

```
+--------+-----------+
| Opcode | Extension |
+--------+-----------+
```

or

```
+--------+-----------+--------------+
| Opcode | Extension | Byte Operand |
+--------+-----------+--------------+
```

or

```
+--------+-----------+--------------+--------------+
| Opcode | Extension | Byte Operand | Byte Operand |
+--------+-----------+--------------+--------------+
```

The extension by specifies the operand format, including register selection,
transfer direction, operand size, and addressing mode. Depending on the
selected format, additional operand bytes may follow.

- Data Movement instructions (`MOV`, `EXG`)
- Binary Arithmetic instructions (`ADC`, `SUB`, `CMP`, `AND`, etc...)

> NOTE: Addressing modes are independent of instruction encoding. The same
> addressing mode may appear in different instruction formats. For example,
> the `BIT` instruction uses Immediate, Absolute or Indirect addressing modes
> without an extension byte, whereas binary arithmetic and data movement use
> the same addressing mode with an extension byte.

---

> Documentation is licensed under CC BY-SA 4.0. <br>
> See https://creativecommons.org/licenses/by-sa/4.0/
