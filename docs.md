# AX8 -> Axle 8-bits

## Overview

&nbsp;&nbsp;&nbsp;&nbsp; O AX8 ou Axle é uma CPU little-endian de 8-bits com um 12-bits de bus endereçável.
Instruções são 8-bits com decodificação ortogonal: Os primeiros 3 bits ditam a
unidade funcional, enquanto últimos 5 bits mais baixos configuram a operação.
Algumas instruções são seguidas por um endereço de 12-bits ou um valor de
8-bits, fazendo-os serem 3-bytes ou 2-bytes no total.

### Registradores

| Registrador | Tamanho | Descrição                                                                                             |
| ----------- | :-----: | ----------------------------------------------------------------------------------------------------- |
| A           |  8-bit  | Acumulador -> Operador primário para todas as operações                                               |
| IX          |  8-bit  | Index register X -> Operador secundário                                                               |
| IY          |  8-bit  | Index register Y -> Operador secundário                                                               |
| PC          | 16-bit  | Program Counter (Contador do Programa). <br>Internamente é 16-bits, mas o nibble mais alto é ignorado |
| FR          | 8-bits  | Flag Register (V, C, N, Z).                                                                           |

\* Não há ponteiro de stack, controle de stack deve ser feita pelo usuário.

| Flag | Bit | Definição                          |
| :--: | --- | ---------------------------------- |
| `Z`  | `0` | `result == 0x00`                   |
| `N`  | `1` | `result[7] & 1`                    |
| `C`  | `2` | `carry-out bit 7`                  |
| `V`  | `3` | `(A[7] == B[7]) && (Y[7] != A[7])` |

\* Mesmo que essa seja a definição normal, é possível que essas flags C e V
sejam modificadas por outras operações.

\* O nibble mais alto sempre é preenchido com zeros.

### Instruções

| Mnemônico | `V C N Z` | Name                     |
| :-------: | :-------: | ------------------------ |
|   `ADD`   | `* * * *` | ADDition                 |
|   `AND`   | `. . * *` | logical AND              |
|   `BCC`   | `. . . .` | Branch if Carry Clear    |
|   `BCS`   | `. . . .` | Branch if Carry Set      |
|   `BEQ`   | `. . . .` | Branch if EQual          |
|   `BMI`   | `. . . .` | Branch if MInus          |
|   `BNQ`   | `. . . .` | Branch if Not eQual      |
|   `BPL`   | `. . . .` | Branch if PLus           |
|   `BVC`   | `. . . .` | Branch if oVerflow Clear |
|   `BVS`   | `. . . .` | Branch if oVerflow Set   |
|   `CLC`   | `. 0 . .` | CLear Carry              |
|   `CLV`   | `0 . . .` | CLear oVerflow           |
|   `CMP`   | `* * * *` | CoMPare                  |
|   `HLT`   | `. . . .` | HaLT                     |
|   `JMP`   | `. . . .` | JuMP                     |
|   `LD `   | `. . * *` | LoaD                     |
|   `LDX`   | `. . * *` | LoaD iX                  |
|   `LDY`   | `. . * *` | LoaD iY                  |
|   `MUL`   | `* * * *` | MULtiply                 |
|   `NOP`   | `. . . .` | No OPeration             |
|   `NOT`   | `. . * *` | logical NOT              |
|   `OR `   | `. . * *` | logical OR               |
|   `SEC`   | `. 1 . .` | SEt Carry                |
|   `ST `   | `. . * *` | STore                    |
|   `STX`   | `. . * *` | STore iX                 |
|   `STY`   | `. . * *` | STore iY                 |
|   `SUB`   | `* * * *` | SUBtract                 |
|   `SHL`   | `. * * *` | logical SHift Left       |
|   `SHR`   | `. * * *` | logical SHift Right      |
|   `XOR`   | `. . * *` | logical eXclusive OR     |
|   `TAX`   | `. . * *` | Transfer A to iX         |
|   `TAY`   | `. . * *` | Transfer A to iY         |
|   `TXA`   | `. . * *` | Transfer iX to A         |
|   `TYA`   | `. . * *` | TRansfer iY to A         |

### Codificação de Instrução

```
[7:5] opcode -> Seleciona a unidade funcional
[4:0] mode   -> Configura operação dentro da unidade
```

Instruções que referenciam memória são 3 bytes:

```
byte 0: Opcode + Mode
byte 1: addr[7:0]
byte 2: addr[11:8] (Nibble mais alto é ignorado)
```

### Tabela de opcodes

| Bits  | Grupo | Descrição                                |
| :---: | :---: | :--------------------------------------- |
| `000` |  SYS  | Operações do sistema                     |
| `001` |  MEM  | Transferência de Memória e Registradores |
| `010` |  ALU  | Aritmética e Lógica                      |
| `011` |  JMP  | Manipulação do Program Counter           |

### Tabela de modos

&nbsp;&nbsp;&nbsp;&nbsp; Os modos são ditos bits 4:0 do opcode. Sua encodificação
é feita da seguinte forma[^1]: Os bits 4:3 determinam se o modo é a
alternação de submodo, e os bits 2:0 ditam qual submodo deve ser configurado
e executado. Qualquer modo não encodificado aqui deve gerar a instrução: `HALT`

Grupo `000`: SYS

|  Mode   | Mnemônico | Operação        |
| :-----: | --------- | --------------- |
| `00000` | `NOP`     | `Consome ciclo` |
| `00100` | `SEC`     | `C <- 1`        |
| `00101` | `CLC`     | `C <- 0`        |
| `00111` | `CLV`     | `V <- 0`        |
| `11111` | `HLT`     | `Halt CPU`      |

Grupo `001`: MEM

|  Mode   | Mnemônico  | Operação          |
| :-----: | ---------- | ----------------- |
| `00000` | `LD  addr` | `A <- mem[addr]`  |
| `00001` | `ST  addr` | `mem[addr] <- A`  |
| `00010` | `LD  [IY]` | `A <- mem[IY]`    |
| `00011` | `ST  [IY]` | `A <- mem[IY]`    |
| `00100` | `LDX addr` | `IX <- mem[addr]` |
| `00101` | `STX addr` | `mem[addr] <- IX` |
| `00110` | `LDY addr` | `IY <- mem[addr]` |
| `00111` | `STY addr` | `mem[addr] <- IY` |
| `01100` | `TAX`      | `IX <- A`         |
| `01101` | `TXA`      | `A <- IX`         |
| `01110` | `TAY`      | `IY <- A`         |
| `01111` | `TYA`      | `A <- IY`         |

Grupo `010`: ALU

|  Mode   | Mnemônico  | Operação                       |
| :-----: | ---------- | ------------------------------ |
| `00000` | `ADD IX`   | `A <- A + IX + C`              |
| `00001` | `SUB IX`   | `A <- A - IX - (~C)`           |
| `00010` | `MUL IX`   | `A <- A[3:0] * IX[3:0]`        |
| `00011` | `AND IX`   | `A <- A & IX`                  |
| `00100` | `OR  IX`   | `A <- A \| IX`                 |
| `00101` | `XOR IX`   | `A <- A ^ IX`                  |
| `00110` | `CMP IX`   | `A - IX, sem writeback`        |
| `00111` | `NOT`      | `A <- ~A`                      |
| `01000` | `INC`      | `A <- A + 1`                   |
| `01001` | `DEC`      | `A <- A - 1`                   |
| `01010` | `INC IX`   | `IX <- IX + 1`                 |
| `01011` | `DEC IX`   | `IX <- IX - 1`                 |
| `01100` | `SHL`      | `A <- A << 1`                  |
| `01101` | `SHR`      | `A <- A >> 1`                  |
| `01110` | `INC IY`   | `IY <- IY + 1`                 |
| `01111` | `DEC IY`   | `IY <- IY - 1`                 |
| `10000` | `ADD imm8` | `A <- A + imm8 + C`            |
| `10001` | `SUB imm8` | `A <- A - imm8 - (~C)`         |
| `10010` | `MUL imm8` | `A <- A[3:0] * imm8[3:0]`      |
| `10011` | `AND imm8` | `A <- A & imm8`                |
| `10100` | `OR  imm8` | `A <- A \| imm8`               |
| `10101` | `XOR imm8` | `A <- A ^ imm8`                |
| `10110` | `CMP imm8` | `A - imm8, sem writeback`      |
| `11000` | `ADD addr` | `A <- A + mem[addr] + C`       |
| `11001` | `SUB addr` | `A <- A - mem[addr] - (~C)`    |
| `11010` | `MUL addr` | `A <- A[3:0] * mem[addr][3:0]` |
| `11011` | `AND addr` | `A <- A & mem[addr]`           |
| `11100` | `OR  addr` | `A <- A \| mem[addr]`          |
| `11101` | `XOR addr` | `A <- A ^ mem[addr]`           |
| `11110` | `CMP addr` | `A - mem[addr], sem writeback` |

Grupo `011`: JMP

|  Mode   | Mnemônico  | Operação                     |
| :-----: | ---------- | ---------------------------- |
| `00000` | `BNQ rel8` | `if Z=0: PC = PC + 2 + rel8` |
| `00001` | `BPL rel8` | `if N=0: PC = PC + 2 + rel8` |
| `00010` | `BCC rel8` | `if C=0: PC = PC + 2 + rel8` |
| `00011` | `BVC rel8` | `if V=0: PC = PC + 2 + rel8` |
| `00100` | `BEQ rel8` | `if Z=1: PC = PC + 2 + rel8` |
| `00101` | `BMI rel8` | `if N=1: PC = PC + 2 + rel8` |
| `00110` | `BCS rel8` | `if C=1: PC = PC + 2 + rel8` |
| `00111` | `BVS rel8` | `if V=1: PC = PC + 2 + rel8` |
| `01000` | `JMP addr` | `PC = addr`                  |

Notas:

- rel8 sempre é um inteiro com sinal, que vai de `-128` à `127`.
- imm8 sempre é um inteiro sem sinal, que vai de `0` à `255`.

### Notas sobre implementação:

&nbsp;&nbsp;&nbsp;&nbsp; Será somente utilizado portas lógicas: AND, OR, NOT e XOR. A implementação
deve ser feita e documentada em blocos de lógica isoladas.

Notas relevantes sobre cada instrução:

- `SUB`: A operação pode ser implementada como: `A + (~B) + C`, já que,
  tecnicamente, isto é equivalente a: `A - B - (~C)`.

### Referências e materiais utilizados:

- [nesdev.org](https://www.nesdev.org/wiki/Instruction_reference)
- [mass:werk](https://www.masswerk.at/6502/6502_instruction_set.html)
- [6502.org](https://6502.org/users/obelisk/6502/instructions.html)
- [CRAFTING A CPU TO RUN PROGRAMS](https://www.youtube.com/watch?v=GYlNoAMBY6o)
- [HOW TRANSISTORS RUN CODE?](https://www.youtube.com/watch?v=HjneAhCy2N4)
- [Building an 8-bit breadboard computer!](https://www.youtube.com/playlist?list=PLowKtXNTBypGqImE405J2565dvjafglHU)

[^1]:
    Em fato, essa encodificação não é obrigatória, mas uma forma de facilitar
    a decodificação em hardware.
