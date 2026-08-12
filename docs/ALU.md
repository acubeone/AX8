## Arithmetic Logic Unit

The AX8 has two kinds of ALU, each are named: `U` and `V`. The `U` ALU handles
simple arithmetic and logical operations, and the `V` ALU handles (un)signed
multiplication and division. **They cannot be used in parallel**.

### ALU - U

The `U` ALU receives inputs: `OP`, `A`, `B` and `Carry`, and always outputs
the result `Y` and the resulting flags: `V`, `C`, `N` and `Z`. All operations in
this unit are single cycle.

- ADC - Add with Carry
  - OP: `000`
  - Operation: `Y <- A + B + Carry`
  - Flags: `[N=*, V=*, C=*, Z=*]`
- SBC - Subtract with Carry
  - OP: `001`
  - Operation: `Y <- A - B - (1 - Carry)`
  - Flags: `[N=*, V=*, C=*, Z=*]`
- AND - Logical AND
  - OP: `010`
  - Operation: `Y <- A & B`
  - Flags: `[N=*, V=0, C=0, Z=*]`
- OR - Logical OR
  - OP: `011`
  - Operation: `Y <- A | B`
  - Flags: `[N=*, V=0, C=0, Z=*]`
- XOR - Logical XOR
  - OP: `100`
  - Operation: `Y <- A ^ B`
  - Flags: `[N=*, V=0, C=0, Z=*]`
- ROR - Rotate Right
  - OP: `101`
  - Operation: `Y <- A <] 1`
  - Flags: `[N=*, V=0, C=*, Z=*]`
- ROL - Rotate Left
  - OP: `110`
  - Operation: `Y <- A [> 1`
  - Flags: `[N=*, V=0, C=*, Z=*]`
- MOV - Logical MOV
  - OP: `111`
  - Operation: `Y <- B`
  - Flags: `[N=*, V=0, C=0, Z=*]`

### ALU - V

The `V` ALU receives inputs: `OP`, `A`, `B` and `Carry`, and always outputs
the result `Y` and the resulting flags: `V`, `C`, `V` and `Z`. This unit is
focused in binary multiplication and division, which can be signed or unsigned.
All operations can take multiple cycles to complete.

- MULU - Multiply Unsigned
  - OP: `00`
  - Operation: `Y <- A * B; A <- Y[7:0]; B <- Y[15:8]`
  - Flags: `[V=0, C=0, N=*, Z=*]`
  - Notes: Multiplication uses unsigned arithmetic. The `Y` low-byte is stored
    in operand `A` and `Y` high byte is stored in operand `B`.
- DIVU - Divide Unsigned
  - OP: `01`
  - Operation: `Q <- A / B; R <- A % B; A <- Q; B <- R`
  - Flags: `[V=*, C=0, N=*, Z=*]`
  - Notes: Division uses unsigned arithmetic. Exception is triggered if operand
    `B` is zero. Overflow flag is set if operand `B` is greater than `A`. The
    quocient is stored in operand `A`, and the remainder is stored in
    operand `B`.
- MULS - Multiply Signed
  - OP: `10`
  - Operation: `signed multiply; A <- Y[7:0]; B <- Y[15:8]`
  - Flags: `[V=0, C=0, N=*, Z=*]`
  - Notes: Multiplication uses signed arithmetic in two's complement. The `Y`
    low-byte is stored in operand `A` and `Y` high byte is stored in operand `B`.
- DIVS - Divide Signed
  - OP: `11`
  - Operation: `signed divide; R <- A % B; A <- Q; B <- R`
  - Flags: `[V=*, C=0, N=*, Z=*]`
  - Notes: Division uses signed arithmetic in two's complement. Exception is
    triggered if operand `B` is zero. Overflow flag is set if operand `B` is
    greater than `A`. The quocient is stored in operand `A`, and the remainder
    is stored in operand `B`.

The `Y` result is always 16-bits. Differently the Unit `U`, the unit `V` always
write back the results into the operand.

### Composition

Some instructions can modify the input or output of each ALU to get another
operation.

- ADD - Add Binary
  - Parent: `ADC`
  - Operation: `Y <- A + B`
  - Modify: The `Carry` is forced to `0`.
- SUB - Subtract Binary
  - Parent: `SBC`
  - Operation: `Y <- A - B`
  - Modify: The `Carry` is forced to `1`.
- INC - Increment
  - Parent: `ADC`
  - Operation: `Y <- A + 1`
  - Modify: The `B` operand is overwritten to `$00` and the `Carry` is
    forced to `1`.
- DEC - Decrement
  - Parent: `ADC`
  - Operation: `Y <- A - 1`
  - Modify: The `B` operand is overwritten to `$ff` and the `Carry` is
    forced to `0`.
- CMP - Compare
  - Parent: `SBC`
  - Operation: `0 <- A - B`
  - Modify: The `Y` result is discarded.
- BIT - Bit Test
  - Parent: `AND`
  - Operation: `0 <- A & B`
  - Modify: The `Y` result is discarded. The `Y[7]` is copied to the `N` and
    the `Y[6]` is copied to `V`
- ASR - Arithmetic Shift Right
  - Parent: `ROR`
  - Operation: `Y <- A >> 1`
  - Modify: The `Carry` is forced to `A[7]`.
- LSR - Logical Shift Right
  - Parent: `ROR`
  - Operation: `Y <- A >> 1`
  - Modify: The `Carry` is forced to `0`.
- LSL - Logical Shift Left
  - Parent: `ROL`
  - Operation: `Y <- A << 1`
  - Modify: The `Carry` is force to `0`.
- NOT - Logical NOT
  - Parent: `XOR`
  - Operation: `Y <- A ^ $ff`
  - Modify: The `B` operand is overwritten to `$ff`.
- CLR - Clear
  - Parent: `MOV`
  - Operation: `Y <- $00`
  - Modify: The `B` operand is overwritten to `$00`.
- NEG - Negate
  - Parent: `SBC`
  - Operation: `Y <- 0 - B`
  - Modify: The `A` operand is overwritten to `$00` and the `Carry` is
    forced to `1`.
