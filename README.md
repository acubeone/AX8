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

|    Register(s)    |  Size  | Description                                                                           |
| :---------------: | :----: | :------------------------------------------------------------------------------------ |
| `A`,`B`, `C`, `D` | 8-bit  | General-purpose data registers used in arithmetic, logic and data movement operations |
| `X`,`Y`, `L`, `H` | 8-bit  | Index registers used for indirect addressing and stack related operations             |
|    `Z` (`Y:X`)    | 16-bit | Merged pointer register formed by `Y` as the high byte and `X` as the low byte        |
|   `SP` (`H:L`)    | 16-bit | Hardware stack pointer formed by `H` as the high byte and `L` as the low byte         |
|       `SR`        | 8-bit  | Status register containing condition flags and interrupt mask bits                    |
|       `VBR`       | 8-bits | Vector Base Register used to relocate exception vector table                          |
|       `PC`        | 16-bit | Program counter holding the address of the next instruction or data fetch             |

#### Register Pairs:

- `Z`: Formed from `Y:X`.
- `SP`: Formed from `H:L`.
- These are merged views, not distinct physical registers

#### Stack Pointer (SP):

The `SP` is the hardware stack pointer.

- `PUSH` decrements `SP`.
- `POP` increments `SP`.

At reset, `SP` is loaded from vector table entry `0`.

#### Status Register (SR):

`SR` contains the following bits.

| Bit | Name | Description                                                                                                                                                      |
| :-: | :--: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `7` | `I1` | **Interrupt Mask 1**. When set to `1`, IRQ1 interrupts are disabled (masked). When cleared, IRQ1 is enabled                                                      |
| `6` | `I0` | **Interrupt Mask 0**. When set to `1`, IRQ0 interrupts are disabled (masked). When cleared, IRQ0 is enabled                                                      |
| `5` | `__` | **Reserved**. Reads as `0`. Must be written as `0` for future compatibility                                                                                      |
| `4` | `__` | **Reserved**. Reads as `0`. Must be written as `0` for future compatibility                                                                                      |
| `3` | `V`  | **Overflow**. Set to `1` if a signed arithmetic operation produces a result outside the range of an 8-bit two's complement integer. Cleared otherwise            |
| `2` | `C`  | **Carry/Borrow**. Set to `1` if an addition generates a carry out of bit 7, or if as subtraction requires a borrow. Also affected by shift and rotate operations |
| `1` | `N`  | **Negative**. Set to `1` if result of operation has bit 7 set. Cleared otherwise                                                                                 |
| `0` | `Z`  | **Zero**. Set to `1` if result of an operation is zero (`$00`). Cleared otherwise                                                                                |

- Flag Behaviour:

| Operation Type                   | Affected Flags     | Behaviour                        |
| :------------------------------- | :----------------- | :------------------------------- |
| Arithmetic (`ADC`, `SBC`, etc.)  | `v`, `C`, `N`, `Z` | Update from result               |
| Logic (`AND`, `OR`, `XOR`, etc.) | `N`, `Z`           | `V` is cleared, `C` is untouched |
| Shift/Rotates                    | `C`, `N`, `Z`      | `V` is cleared                   |
| Move (`MOV`)                     | `N`, `Z`           | `V` and `C` are untouched        |
| Compare (`CMP`)                  | `V`, `C`, `N`, `Z` | Updated from subtraction result  |
| Increment/Decrement              | `N`, `Z`           | `V` and `C` are untouched        |

#### Vector Base Register (VBR):

`VBR` selects the base address of the relocatable exception vector table.

- It is readable and writable only through `MOV`
- It is initialized to `$00` at reset

#### Program Counter (PC):

`PC` holds the address of the next byte to be fetched

- It increments during sequential execution
- It is Overwritten by jumps, branches and subroutine calls
- It is saved on the stack during interrupts and subroutine calls, then restored on return

At reset, `PC` is loaded from vector table entry `1`.

## Interrupts and Exceptions

- [TXT documentation](./docs/vecs.txt)
