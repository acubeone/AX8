# AX8: Axle 8-bits

## Overview

&nbsp;&nbsp;&nbsp;&nbsp; O AX8 ou Axle é uma CPU CISC little-endian de 8-bits com um bus de 12-bits
endereçável. Instruções são 8-bits com decodificação ortogonal: Os bits 7:5
ditam a unidade funcional, enquanto bits 4:0 mais baixos configuram a operação.
Algumas instruções são seguidas por um endereço de 12-bits ou um valor de
8-bits, fazendo-os serem 3-bytes ou 2-bytes no total.

&nbsp;&nbsp;&nbsp;&nbsp; Todos os programas se iniciam pelo endereço contido em `0x0000`,
ao reset/powerup da CPU, dois bytes são lidos nesse endereço e registrados no
Program Counter. Por conveniência, o endereço `0x0002` pode ser utilizado
como Stack Pointer.

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
| `V`  | `3` | `(A[7] != Y[7]) && (B[7] != Y[7])` |

\* Mesmo que essa seja a definição normal, é possível que as flags V e C
sejam modificadas por outras operações.

\* As flags N e Z sempre são modificadas por qualquer instrução que passe
pela ALU.

\* O nibble mais alto sempre é preenchido com zeros.

### Instruções

| Mnemônico | `V C N Z` | Nome                     |
| :-------: | :-------: | ------------------------ |
|   `ADC`   | `* * * *` | ADdition with Carry      |
|   `AND`   | `. . * *` | logical AND              |
|   `BCC`   | `. . . .` | Branch if Carry Clear    |
|   `BCS`   | `. . . .` | Branch if Carry Set      |
|   `BEQ`   | `. . . .` | Branch if EQual          |
|   `BMI`   | `. . . .` | Branch if MInus          |
|   `BNQ`   | `. . . .` | Branch if Not eQual      |
|   `BPL`   | `. . . .` | Branch if PLus           |
|   `BRA`   | `. . . .` | BRAnch                   |
|   `BVC`   | `. . . .` | Branch if oVerflow Clear |
|   `BVS`   | `. . . .` | Branch if oVerflow Set   |
|   `CLC`   | `. 0 . .` | CLear Carry              |
|   `CLV`   | `0 . . .` | CLear oVerflow           |
|   `CMP`   | `* * * *` | CoMPare                  |
|   `DEC`   | `. . * *` | DECrement                |
|   `HLT`   | `. . . .` | HaLT                     |
|   `INC`   | `. . * *` | INCrement                |
|   `JMP`   | `. . . .` | JuMP                     |
|   `LD `   | `. . * *` | LoaD                     |
|   `LDX`   | `. . * *` | LoaD iX                  |
|   `LDY`   | `. . * *` | LoaD iY                  |
|   `MUL`   | `* 0 * *` | MULtiply                 |
|   `NOP`   | `. . . .` | No OPeration             |
|   `NOT`   | `. . * *` | logical NOT              |
|   `OR `   | `. . * *` | logical OR               |
|   `ROL`   | `. * * *` | logical ROtate Left      |
|   `ROR`   | `. * * *` | logical ROtate Right     |
|   `SEC`   | `. 1 . .` | SEt Carry                |
|   `SEV`   | `1 . . .` | SEt oVerflow             |
|   `ST `   | `. . * *` | STore                    |
|   `STX`   | `. . * *` | STore iX                 |
|   `STY`   | `. . * *` | STore iY                 |
|   `SBC`   | `* * * *` | SuBtract with Carry      |
|   `SHL`   | `. * * *` | logical SHift Left       |
|   `SHR`   | `. * 0 *` | logical SHift Right      |
|   `XOR`   | `. . * *` | logical eXclusive OR     |
|   `TAX`   | `. . * *` | Transfer A to iX         |
|   `TAY`   | `. . * *` | Transfer A to iY         |
|   `TXA`   | `. . * *` | Transfer iX to A         |
|   `TXY`   | `. . * *` | Transfer iX yo iY        |
|   `TYA`   | `. . * *` | Transfer iY to A         |
|   `TYX`   | `. . * *` | Transfer IY to iX        |

### Codificação de Instrução

```
Instrução:
  Bit  7 6 5 4 3 2 1 0
  Name G G G S S C C C

  [7:5] G = Group     -> Seleciona a unidade funcional
  [4:3] S = Subgroup  -> Subgrupo funcional
  [2:0] C = Execution -> Unidade de execução

Modos:
  Implied: (1-byte) | MNEMONIC
    byte 0: instrução
  Zeropage: (1-byte) | MNEMONIC [IY]
    byte 0: instrução
  Immediate: (2-bytes) | MNEMONIC #imm8
    byte 0: instrução
    byte 1: imm8[7:0] (sem sinal: 0 a 255)
  Relative: (2-bytes) | MNEMONIC rel8
    byte 0: instrução
    byte 1: rel8[7:0] (com sinal: -128 a 127)
  Absolute: (3-bytes) | MNEMONIC addr
    byte 0: instrução
    byte 1: addr[7:0]
    byte 2: addr[11:8] (nibble mais alto é ignorado)
```

### Tabela de opcodes

| Bits  |   Grupo    | Descrição                                |
| :---: | :--------: | :--------------------------------------- |
| `000` |   System   | Operações do sistema                     |
| `001` |   Memory   | Transferência de Memória e Registradores |
| `010` | Arithmetic | Aritmética e Lógica                      |
| `011` |   Unary    | Aritmética Unária                        |
| `100` |    Jump    | Manipulação do Program Counter           |

### Tabela de modos

&nbsp;&nbsp;&nbsp;&nbsp; Os modos são ditos pelos bits 4:0 do opcode. Sua encodificação
é feita da seguinte forma[^1]: Os bits 4:3 determinam se o modo é a
alternação de submodo, e os bits 2:0 ditam qual submodo deve ser configurado
e executado. Qualquer modo não encodificado aqui deve gerar a instrução: `HALT`

Grupo `000`: System

```
Encoding:
  NOP:
    4 3 2 1 0
    0 0 0 0 0
  Flag Manipulation:
    4 3 2 1 0
    0 0 1 F B
    - F = Flag -> 0=C, 1=V
    - B = Bit -> 0=Clear, 1=Set
  HALT:
    4 3 2 1 0
    0 1 x x x -> HALT
    1 0 x x x -> HALT
    1 1 x x 0 -> HALT
    1 1 1 1 1 -> Official HALT
```

|  Mode   | Mnemônico | Operação        |
| :-----: | --------- | --------------- |
| `00000` | `NOP`     | `Consome ciclo` |
| `00100` | `CLC`     | `C <- 0`        |
| `00101` | `SEC`     | `C <- 1`        |
| `00110` | `CLV`     | `V <- 0`        |
| `00111` | `SEV`     | `V <- 1`        |
| `01xxx` | `XXX`     | `Halt CPU`      |
| `10xxx` | `XXX`     | `Halt CPU`      |
| `11xx0` | `XXX`     | `Halt CPU`      |
| `11111` | `HLT`     | `Halt CPU`      |

Grupo `001`: Memory

```
Enconding:
  Memory:
    4 3 2 1 0
    0 M D R R
    - M  = Mode      -> 0=Absolute, 1=Indirect
    - D  = Direction -> 0=Read, 1=Write
    - RR = Register  -> 00=A, 01=IX, 10=IY, 11=HALT
  Transfer:
    4 3 2 1 0
    1 S S D D
    - SS = Source      -> 00=A, 01=IX, 10=IY, 11=HALT
    - DD = Destination -> 00=A, 01=IX, 10=IY, 11=HALT
```

|  Mode   | Mnemônico  | Operação          |
| :-----: | ---------- | ----------------- |
| `00000` | `LD addr`  | `A <- mem[addr]`  |
| `00001` | `LDX addr` | `IX <- mem[addr]` |
| `00010` | `LDY addr` | `IY <- mem[addr]` |
| `00011` | `XXX`      | `Halt CPU`        |
| `00100` | `ST addr`  | `mem[addr] <- A`  |
| `00101` | `STX addr` | `mem[addr] <- IX` |
| `00110` | `STY addr` | `mem[addr] <- IY` |
| `00111` | `XXX`      | `Halt CPU`        |
| `01000` | `LD [IY]`  | `A <- mem[addr]`  |
| `01001` | `LDX [IY]` | `IX <- mem[addr]` |
| `01010` | `LDY [IY]` | `IY <- mem[addr]` |
| `01011` | `XXX`      | `Halt CPU`        |
| `01100` | `ST [IY]`  | `mem[IY] <- A`    |
| `01101` | `STX [IY]` | `mem[IY] <- IX`   |
| `01110` | `STY [IY]` | `mem[IY] <- IY`   |
| `01111` | `XXX`      | `Halt CPU`        |
| `10000` | `NOP`      | `Sem operação`    |
| `10001` | `TAX`      | `IX <- A`         |
| `10010` | `TAY`      | `IY <- A`         |
| `10011` | `XXX`      | `Halt CPU`        |
| `10100` | `TXA`      | `A <- IX`         |
| `10101` | `NOP`      | `Sem operação`    |
| `10110` | `TXY`      | `IY <- IX`        |
| `10111` | `XXX`      | `Halt CPU`        |
| `11000` | `TYA`      | `A <- IY`         |
| `11001` | `TYX`      | `IX <- IY`        |
| `11010` | `NOP`      | `Sem operação`    |
| `11011` | `XXX`      | `Halt CPU`        |
| `111xx` | `XXX`      | `Halt CPU`        |

Grupo `010`: Arithmetic

```
Encoding:
  4 3 2 1 0
  S S O O O
  - SS  = Source    -> 00=IX, 01=HALT, 10=Absolute, 11=Immediate
  - OOO = Operation -> 000=ADC, 001=SBC, 010=MUL, 011=AND,
                       100=OR, 101=XOR, 110=CMP, 111=HALT
```

|  Mode   | Mnemônico  | Operação                       |
| :-----: | ---------- | ------------------------------ |
| `00000` | `ADC IX`   | `A <- A + IX + C`              |
| `00001` | `SBC IX`   | `A <- A - IX - (1 - C)`        |
| `00010` | `MUL IX`   | `A <- A[3:0] * IX[3:0]`        |
| `00011` | `AND IX`   | `A <- A & IX`                  |
| `00100` | `OR  IX`   | `A <- A \| IX`                 |
| `00101` | `XOR IX`   | `A <- A ^ IX`                  |
| `00110` | `CMP IX`   | `A - IX, sem writeback`        |
| `00111` | `XXX`      | `Halt CPU`                     |
| `01xxx` | `XXX`      | `Halt CPU`                     |
| `10000` | `ADC addr` | `A <- A + mem[addr] + C`       |
| `10001` | `SBC addr` | `A <- A - mem[addr] - (1 - C)` |
| `10010` | `MUL addr` | `A <- A[3:0] * mem[addr][3:0]` |
| `10011` | `AND addr` | `A <- A & mem[addr]`           |
| `10100` | `OR  addr` | `A <- A \| mem[addr]`          |
| `10101` | `XOR addr` | `A <- A ^ mem[addr]`           |
| `10110` | `CMP addr` | `A - mem[addr], sem writeback` |
| `10111` | `XXX`      | `Halt CPU`                     |
| `11000` | `ADC imm8` | `A <- A + imm8 + C`            |
| `11001` | `SBC imm8` | `A <- A - imm8 - (1 - C)`      |
| `11010` | `MUL imm8` | `A <- A[3:0] * imm8[3:0]`      |
| `11011` | `AND imm8` | `A <- A & imm8`                |
| `11100` | `OR  imm8` | `A <- A \| imm8`               |
| `11101` | `XOR imm8` | `A <- A ^ imm8`                |
| `11110` | `CMP imm8` | `A - imm8, sem writeback`      |
| `11111` | `XXX`      | `Halt CPU`                     |

Grupo `011`: Unary

```
Enconding:
  Shift/Bit:
    4 3 2 1 0
    0 0 O O O
    - OOO = Operation -> 000=SHL, 001=SHR, 010|011|100=HALT,
                         101=NOT, 110=ROL, 111=ROR
  Increment/Decrement:
    4 3 2 1 0
    0 1 D R R
    - D  = Decrement -> 0=INC, 1=DEC
    - RR = Register  -> 00=A, 01=IX, 10=IY, 11=HALT
  HALT:
    4 3 2 1 0
    1 x x x x -> HALT
```

|  Mode   | Mnemônico | Operação                        |
| :-----: | --------- | ------------------------------- |
| `00000` | `SHL`     | `A <- A << 1; C <- [7..0] <- 0` |
| `00001` | `SHR`     | `A <- A >> 1; 0 -> [7..0] -> C` |
| `00010` | `XXX`     | `Halt CPU`                      |
| `00011` | `XXX`     | `Halt CPU`                      |
| `00100` | `XXX`     | `Halt CPU`                      |
| `00101` | `NOT`     | `A <- ~A`                       |
| `00110` | `ROL`     | `A <- A <] 1; C <- [7..0] <- C` |
| `00111` | `ROR`     | `A <- A [> 1; C -> [7..0] -> C` |
| `01000` | `INC`     | `A <- A + 1`                    |
| `01001` | `INC IX`  | `IX <- IX + 1`                  |
| `01010` | `INC IY`  | `IY <- IY + 1`                  |
| `01011` | `XXX`     | `Halt CPU`                      |
| `01100` | `DEC`     | `A <- A - 1`                    |
| `01101` | `DEC IX`  | `IX <- IX - 1`                  |
| `01110` | `DEC IY`  | `IY <- IY - 1`                  |
| `01111` | `XXX`     | `Halt CPU`                      |
| `1xxxx` | `XXX`     | `Halt CPU`                      |

Grupo `100`: Jump

```
Encoding
  Conditional Branch:
    4 3 2 1 0
    0 0 T F F
    - T  = Test -> 0=Test if Clear, 1=Test if Set
    - FF = Flag -> 00=Z, 01=C, 10=N, 11=V
  Unconditional Control Flow:
    4 3 2 1 0
    1 0 0 O O
    - OO = Operation -> 00=BRA, 01=JMP, 10|11=Reserved/NO-OP
  HALT:
    4 3 2 1 0
    0 1 x x x -> HALT
    1 1 x x x -> HALT
```

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
| `01xxx` | `XXX`      | `Halt CPU`                   |
| `10000` | `BRA rel8` | `PC = PC + 2 + rel8`         |
| `10001` | `JMP addr` | `PC = addr`                  |
| `10010` | `NOP`      | `Reservado: Sem operação`    |
| `10011` | `NOP`      | `Reservado: Sem operação`    |
| `101xx` | `XXX`      | `Halt CPU`                   |
| `11xxx` | `XXX`      | `Halt CPU`                   |

Notas:

- `XXX` significa `indefinido`, logo sempre ocorrerar um `HLT`
- rel8 sempre é um inteiro com sinal, que vai de `-128` à `127`.
- imm8 sempre é um inteiro sem sinal, que vai de `0` à `255`.

### Unidade Lógica de Aritmética

&nbsp;&nbsp;&nbsp;&nbsp;A ULA é a unidade lógica de aritmética principal do AX8, nela é possível
computar duas entradas A e B, e retornar o resultado Y, junto com as flags
apropriadas. A ULA é limitada a computação de números inteiros de 8-bits,
sendo sua saída também limitada a 8-bits.

|   OP   | Nome  | Operação               | Carry                | Overflow            |
| :----: | :---: | ---------------------- | -------------------- | ------------------- |
| `0000` | `ADC` | `Y <- A + B + C`       | carry-out            | sobrecarga de sinal |
| `0001` | `SBC` | `Y <- A - B - (1 - C)` | borrow invertido     | sobrecarga de sinal |
| `0010` | `MUL` | `Y <- A[3:0] * B[3:0]` | zero                 | Y > 0x0F            |
| `0011` | `AND` | `Y <- A & B`           | ---                  | ---                 |
| `0100` | `OR ` | `Y <- A \| B`          | ---                  | ---                 |
| `0101` | `XOR` | `Y <- A ^ B`           | ---                  | ---                 |
| `0110` | `ROL` | `Y <- A <] 1`          | A\[7\] antes do roll | ---                 |
| `0111` | `ROR` | `Y <- A [> 1`          | A\[0\] antes do roll | ---                 |
| `1000` | `MOV` | `Y <- B`               | ---                  | ---                 |
| `1xx1` | `HLT` | `Sem operação`         | ---                  | ---                 |

### Notas sobre implementação:

&nbsp;&nbsp;&nbsp;&nbsp; Será somente utilizado portas lógicas: AND, OR, NOT e XOR. A implementação
deve ser feita e documentada em blocos de lógica isoladas.

Notas relevantes sobre cada instrução:

- `ADC`: Por causa da natureza da instrução, é recomendado utilizar 'CLC' para
  limpar o Carry
- `SBC`: A operação pode ser implementada como: `A + (~B) + C`, já que,
  tecnicamente, isto é equivalente a: `A - B - (~C)`. Por causa desta natureza,
  o resultado sempre está uma unidade maior, portanto, antes de qualquer
  operação, é recomendado usar o `SEC` para ativar o Carry.
- `SHL` e `SHR`: Não tem opcodes próprios na ALU, as operações são feitas como
  `ROL` e `ROR`, mas com a flag carry em `0`
- `NOT`: Pode ser implementado como: `A XOR 0xFF`
- `CMP`: O resultado da operação pode ser interpretado como: `ZC = A <=> B`
- `STY` e `LDY`: O modo indireto dessas instruções são válidos, mas raramente
  úteis na prática
- `SIZE`: Internatemente, cada instrução é codificada com um tamanho, sendo
  estes tamanhos a quantidade de bytes que necessárias para fetch:
  `00=None; 01=Byte; 10=Word; 11=None`

Notas sobre as flags:

- `V`: O resultado da sobrecarga de sinal em `ADC` e `SBC` vem do sexto
  carry (`c6`) e o carry resultante (`cout`), então `V = c6 xor cout`

  | Relação |  Z  |  C  |   N    |
  | :-----: | :-: | :-: | :----: |
  | `A < B` | `0` | `0` | `Y[7]` |
  | `A = B` | `1` | `1` |  `0`   |
  | `A > B` | `0` | `1` | `Y[7]` |

### Referências e materiais utilizados:

- [nesdev.org](https://www.nesdev.org/wiki/Instruction_reference)
- [mass:werk](https://www.masswerk.at/6502/6502_instruction_set.html)
- [6502.org](https://6502.org/users/obelisk/6502/instructions.html)
- [CRAFTING A CPU TO RUN PROGRAMS](https://www.youtube.com/watch?v=GYlNoAMBY6o)
- [HOW TRANSISTORS RUN CODE?](https://www.youtube.com/watch?v=HjneAhCy2N4)
- [Building an 8-bit breadboard computer!](https://www.youtube.com/playlist?list=PLowKtXNTBypGqImE405J2565dvjafglHU)
- [Wikipédia - Arithmetic Logic Unit](https://en.wikipedia.org/wiki/Arithmetic_logic_unit)
- [Wikipédia - Adder Eletronics](<https://en.wikipedia.org/wiki/Adder_(electronics)>)
- [Wikipédia - Adder Subtractor](https://en.wikipedia.org/wiki/Adder%E2%80%93subtractor)

[^1]:
    Em fato, essa encodificação não é obrigatória, mas uma forma de facilitar
    a decodificação em hardware.
