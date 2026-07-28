## Exception and Interrupt Vectors

The AX8 uses a vectored exception and interrupt system, just like the M68K, Z80
and MOS6502. Fixed vectores are stored at low memory, while relocatable vectors
can use the `VBR` as the base address.

The `VBR` acts as the high-byte of the vector address.

### Vector Table and Descriptions

| Number |  Offset   | Description                                      |
| :----: | :-------: | :----------------------------------------------- |
|  ` 0`  |  `$0000`  | Initial stack pointer, loaded into SP at reset   |
|  ` 1`  |  `$0002`  | Initial program counter, loaded into PC at reset |
|  ` 2`  | `VBR:$04` | Non-maskable interrupt                           |
|  ` 3`  | `VBR:$06` | Reserved. Not fetched by the processor           |
|  ` 4`  | `VBR:$08` | Interrupt Request `0`. Maskable by `SR.I0`       |
|  ` 5`  | `VBR:$0a` | Interrupt Request `1`. Maskable by `SR.I1`       |
|  ` 6`  | `VBR:$0c` | Reserved. Not fetched by the processor           |
|  ` 7`  | `VBR:$0e` | Reserved. Not fetched by the processor           |
|  ` 8`  | `VBR:$10` | Invalid opcode fetch                             |
|  ` 9`  | `VBR:$12` | Divide opration with zero divisor                |
|  `10`  | `VBR:$14` | Reserved. Not fetched by the processor           |
|  `11`  | `VBR:$16` | Reserved. Not fetched by the processor           |
|  `12`  | `VBR:$18` | Software trap 0                                  |
|  `13`  | `VBR:$1a` | Software trap 1                                  |
|  `14`  | `VBR:$1c` | Software trap 2                                  |
|  `15`  | `VBR:$1e` | Software trap 3                                  |

> All vectors are 16-bit addresses stored in little-endian. Each vector
> address store the handler address to be fetched.

### Interrupt handling

Except for reset, every interrupt or exception do as follows:

1. Push `PCH` into stack, decrement `SP`
2. Push `PCL` into stack, decrement `SP`
3. Push `SR` into stack, decrement `SP`
4. Load handler address from corresponding vector into `PC`
5. Continues execution at new handler address

For reset, it happens as follows:

1. Set `VBR` to `$00`
2. Read vector `0` address and store contents into `SP`
3. Read vector `1` address and store contents into `PC`
4. Starts execution at `PC` address

---

> Documentation is licensed under CC BY-SA 4.0. <br>
> See https://creativecommons.org/licenses/by-sa/4.0/
