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

## Interrupts and Exceptions

- [Documentation](./docs/Vectors.md)

## Addressing Modes

- [Documentation](./docs/AddressModes.md)

---

> Documentation is licensed under CC BY-SA 4.0. <br>
> See https://creativecommons.org/licenses/by-sa/4.0/
