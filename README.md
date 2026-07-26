# AX8: Axle 8-bit Microprocessor

## Overview

&ensp;&ensp;&ensp;&ensp;The AX8 or Axle is a 8-bit CISC microprocessor with a strictly little-endian
memory model. It provides an 8-bit internal data path and a 16-bit address bus,
enabling direct addressing of up to 64KB of memory space.

---

## Registers

|    Register(s)    |  Size  | Description                                                                                                           |
| :---------------: | :----: | :-------------------------------------------------------------------------------------------------------------------- |
| `A`,`B`, `C`, `D` | 8-bit  | General-purpose data registers used in arithmetic, logic and move operations.                                         |
| `X`,`Y`, `L`, `H` | 8-bit  | Index registers used for indirect addressing and stack-related operations.                                            |
|    `Z` (`Y:X`)    | 16-bit | Merged form of `Y`(high byte) and `X` (low byte). Used for 16-bit indirect memory addressing.                         |
|   `SP` (`H:L`)    | 16-bit | Merged form of `H` (high byte) and `L` (low byte). Functions as the hardware stack pointer.                           |
|       `SR`        | 8-bit  | Status registers containing condition flags (Zero, Carry, Negative, etc.). These flags control conditional branching. |
|       `VBR`       | 8-bits | Vector Base Register. Supplies the high byte of the relocatable exception vector table.                               |
|       `PC`        | 16-bit | Program counter holding the address of the next instruction or data to be fetched.                                    |

### Merged Pairs:

- The index registers may be combined into two 16-bit pointer registers.
- `Z`: Formed from `Y:X`.
- `SP`: Formed from `H:L`.
- These pairs are not physically distinct registers.

### Stack Pointer (SP):

- This register is the hardware stack pointer.
- The microprocessor automatically increments or decrements based on operations.
- `PUSH` decrements `SP`.
- `POP` increments `SP`.
- The initial value of `SP` is set from the vector address: `$fffd:$fffc`.

### Status Register (SR):

- The Status Register is a 8-bit register containing condition flags and interrupt
  mask bits.
- Each bit represents the outcome of arithmetc, logic and data movement operations.
- Conditional branch instructions can inspect specific flags to determine whether
  to alter program flow.
- Bit Layout:

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

| Operation Type                   | Affected Flags     | Behaviour                                      |
| :------------------------------- | :----------------- | :--------------------------------------------- |
| Arithmetic (`ADC`, `SBC`, etc.)  | `v`, `C`, `N`, `Z` | All four flags are updated based on the result |
| Logic (`AND`, `OR`, `XOR`, etc.) | `N`, `Z`           | `V` is cleared to `0`. `C` is untouched        |
| Shift/Rotates                    | `C`, `N`, `Z`      | `V` is cleared to `0`                          |
| Move (`MOV`)                     | `N`, `Z`           | `V` and `C` are untouched                      |
| Compare (`CMP`)                  | `V`, `C`, `N`, `Z` | All four flags are updated based on the result |
| Increment/Decrement              | `N`, `Z`           | `V` and `C` are untouched                      |

### Vector Base Register (VBR):

- VBR controls the location of the relocatable vector table.
- Can only be modified or read by `MOV` instructions.
- Supplies the high byte of the base address of relocatable exception vectors 2-10.
- Initialized to `$00` at reset.

### Program Counter (PC):

- The PC contains the address of the next byte to be fetched. It is
  automatically updated by the control unit:
  - Incremented by one after each data fetch operation during sequential
    execution.
  - Overwritten by jump, branch, or subroutine call instructions.
  - Stored on the stack during subroutine calls or interrupt requests, and
    restored upon return.
- The initial value of `PC` is set from the vector address: `$ffff:$fffe`.

---

## Interrupts and Exceptions

&ensp;&ensp;&ensp;&ensp;The AX8 implements a vectored exception system. Vectors are 16-bit addressed
stored in a vector table. The table location depends on vector type:

- **Fixed vectors** (0-1) reside at hardwired low address and are not affected
  by **Vector Base Register (VBR)**.
- **Relocatable vectors** (2-10) base address can be determined by the
  **Vector Base Register (VBR)**.

### Vector Table

| Number |  Address  | Source    | Description                                      |
| :----- | :-------: | :-------- | :----------------------------------------------- |
| 0      |  `$0000`  | InitialSP | Initial stack pointer, loaded into SP at reset   |
| 1      |  `$0002`  | ResetPC   | Initial program counter, loaded into PC at reset |
| 2      | `VBR:$04` | NMI       | Non-maskable interrupt                           |
| 3      | `VBR:$06` | IRQ0      | Interrupt Request 0. Maskable by SR.I0           |
| 4      | `VBR:$08` | IRQ1      | Interrupt Request 1. Maskable by SR.I1           |
| 5      | `VBR:$0a` | Illegal   | Invalid opcode fetch                             |
| 6      | `VBR:$10` | DivZero   | Divide operation with zero divisor               |
| 7      | `VBR:$12` | TRAP0     | Software trap 0                                  |
| 8      | `VBR:$14` | TRAP1     | Software trap 1                                  |
| 9      | `VBR:$16` | TRAP2     | Software trap 2                                  |
| 10     | `VBR:$18` | TRAP3     | Software trap 3                                  |

### Interrupt Masking and Priority

> IRQ0 and IRQ1 are asserted via external signals. The processor samples these
> signals during instruction fetch and services them only when the
> corresponding mask bit is cleared.

> NMI is non-maskable. It is serviced immediately at instruction fetch
> regardless of `SR` state.

| Source  | Priority | Note                                                            |
| :------ | :------: | :-------------------------------------------------------------- |
| Reset   |   `0`    | Is serviced immediately at external trigger                     |
| NMI     |   `1`    | Serviced at the beginning of instruction fetch                  |
| IRQ0    |   `2`    | If not-masked is serviced at the beginning of instruction fetch |
| IRQ1    |   `3`    | Same as IRQ0                                                    |
| Illegal |   `4`    | Serviced after instruction decoding                             |
| DivZero |   `5`    | Serviced at `DIV` execution if divisor is `0`                   |
| TRAPn   |   `6`    | Serviced at `TRAP #n` execution                                 |

### Interrupt behaviour

&ensp;&ensp;&ensp;&ensp;Interrupts always (except reset) always stores previous processor state
into stack:

- Push high-byte of `PC` into stack, and decrement `SP`
- Push low-byte of `PC` into stack, and decrement `SP`
- Push Status Register (SR) into stack and decrement `SP`
- Read value from vector addres and stores into `SP`
- Continue normal execution at new `PC` address

<details open="false">
<summary>Interrupt behaviour states and execution</summary>

```
Reset Behaviour:
  0) 'VBR' is set to '$00'
  1) Read 16-bit value from '$0000' ('$0000'=low byte, '$0001'=high byte) and
     loads into 'SP'
  2) Read 16-bit value from '$0002' ('$0002'=low byte, '$0003'=high byte) and
     loads into 'PC'
  3) Instruction execution begins at address stored in 'PC'

Non-Maskable Interrupt:
  0) Checks NMI latch before instruction fetching. If is set, proceed
  1) Pushes 'PCH' into stack, decrement 'SP'
  2) Pushes 'PCL' into stack, decrement 'SP'
  3) Pushes 'SR' into stack, decrement 'SP'
  4) Read 16-bit value from 'VBR:$04' ('VBR:$04'=low byte, '$VBR:$05'=high byte)
     and loads into 'PC'
  5) Instruction fetch continues at new 'PC'

Interrupt Request:
  0) Checks IRQ0/IRQ1 latch before instruction fetching. If is set, proceed
  1) Checks if corresponding mask bit is set. If cleared, proceed
  2) Pushes 'PCH' into stack, decrement 'SP'
  3) Pushes 'PCL' into stack, decrement 'SP'
  4) Pushes 'SR' into stack, decrement 'SP'
  5) IRQ0:
    - Read 16-bit value from 'VBR:$06' ('VBR:$06'=low byte, '$VBR:$07'=high byte)
      and loads into 'PC'
  5) IRQ1:
    - Read 16-bit value from 'VBR:$08' ('VBR:$08'=low byte, '$VBR:$09'=high byte)
      and loads into 'PC'
  6) Instruction fetch continues at new 'PC'

Illegal Instruction:
  0) At end of instruction decoding, check if was illegal. If it was, proceed
  1) Pushes 'PCH' into stack, decrement 'SP'
  2) Pushes 'PCL' into stack, decrement 'SP'
  3) Pushes 'SR' into stack, decrement 'SP'
  4) Read 16-bit value from 'VBR:$0a' ('VBR:$0a'=low byte, '$VBR:$0a'=high byte)
     and loads into 'PC'
  5) Fetch instruction at new 'PC'

Division By Zero:
  0) At 'DIV' execution check if divisor is '$00', if is proceed
  1) Pushes 'PCH' into stack, decrement 'SP'
  2) Pushes 'PCL' into stack, decrement 'SP'
  3) Pushes 'SR' into stack, decrement 'SP'
  4) Read 16-bit value from 'VBR:$10' ('VBR:$10'=low byte, '$VBR:$11'=high byte)
     and loads into 'PC'
  5) Instruction fetch continues at new 'PC'

Software Trap:
  0) After 'TRAP #n' execution proceed
  1) Pushes 'PCH' into stack, decrement 'SP'
  2) Pushes 'PCL' into stack, decrement 'SP'
  3) Pushes 'SR' into stack, decrement 'SP'
  4) 'TRAP #0':
    - Read 16-bit value from 'VBR:$12' ('VBR:$12'=low byte, '$VBR:$13'=high byte)
      and loads into 'PC'
  4) 'TRAP #1':
    - Read 16-bit value from 'VBR:$14' ('VBR:$14'=low byte, '$VBR:$15'=high byte)
      and loads into 'PC'
  4) 'TRAP #2':
    - Read 16-bit value from 'VBR:$16' ('VBR:$16'=low byte, '$VBR:$17'=high byte)
      and loads into 'PC'
  4) 'TRAP #3':
    - Read 16-bit value from 'VBR:$18' ('VBR:$18'=low byte, '$VBR:$19'=high byte)
      and loads into 'PC'
  5) Instruction fetch continues at new 'PC'
```

</details>
