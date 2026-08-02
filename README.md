# AX8: Axle 8-bit Microprocessor

## Overview

AX8, also called Axle, is an 8-bit CISC microprocessor with a strictly
little-endian memory model. It uses 8-bit internal. It uses an 8-bit internal
data path and a 16-bit address bus, allowing direct access to up 64KB of memory.

### Key Features

- 8-bit data path
- 16-bit address bus
- Little-endian memory layout
- General-purpose data and index registers
- Hardware stack pointer
- Status register with condition flags and interrupt masks
- Vectored interrupt and exception handling
- Support for register, immediate, absolute, indirect and relative addresing modes

### Registers

- [Documentation](./docs/Registers.md)

### Interrupts and Exceptions

- [Documentation](./docs/Vectors.md)

### Addressing Modes

- [Documentation](./docs/AddressModes.md)

### Arithmetic Logic Unit

- [Documentation](./docs/ALU.md)

### Instruction Set

- [ADC/ADD](./docs/instructions/adc_add.md)
- [AND](./docs/instructions/and.md)
- [ASR](./docs/instructions/asr.md)
- [Bcc](./docs/instructions/bcc.md)
- [BCHG](./docs/instructions/bchg.md)
- [BCLR](./docs/instructions/bclr.md)
- [BIT](./docs/instructions/bit.md)
- [BRA](./docs/instructions/bra.md)
- [BSET](./docs/instructions/bset.md)
- [BSR](./docs/instructions/bsr.md)
- [BTST](./docs/instructions/btst.md)
- [CLR](./docs/instructions/clr.md)
- [CMP](./docs/instructions/cmp.md)
- [DEC](./docs/instructions/dec.md)
- [DIVU/DIVS](./docs/instructions/divu_divs.md)
- [EXG](./docs/instructions/exg.md)
- [HALT](./docs/instructions/halt.md)
- [INC](./docs/instructions/inc.md)
- [JMP](./docs/instructions/jmp.md)
- [JSR](./docs/instructions/jsr.md)
- [LSL/LSR](./docs/instructions/lsl_lsr.md)
- [MOV](./docs/instructions/mov.md)
- [MULU/MULS](./docs/instructions/mulu_muls.md)
- [NEG](./docs/instructions/neg.md)
- [NOP](./docs/instructions/nop.md)
- [NOT](./docs/instructions/not.md)
- [OR](./docs/instructions/or.md)
- [ROL/ROR](./docs/instructions/rol_ror.md)
- [RTI](./docs/instructions/rti.md)
- [RTS](./docs/instructions/rts.md)
- [SBC/SUB](./docs/instructions/sbc_sub.md)
- [TRAP](./docs/instructions/trap.md)
- [XOR](./docs/instructions/xor.md)

---

> Documentation is licensed under CC BY-SA 4.0. <br>
> See https://creativecommons.org/licenses/by-sa/4.0/
