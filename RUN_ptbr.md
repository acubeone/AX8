# RUN

O AX8 é primariamente inspecionado com o Logisim-Evolution. <br>
Simulação e inspeção do Verilog também é possível através do Makefile.

---

## 1) Instalação do Logisim-Evolution (Workflow primário)

Releases do Logisim-Evolution: https://github.com/logisim-evolution/logisim-evolution/releases

### Linux

1. Instale o Java (JRE 11+ recomendado)
2. Baixe o arquivo `.jar` na aba de releases do Logisim
3. Execute: <br>

```bash
java -jar logisim-evolution-*.jar
```

### Windows

1. Baixe o instalador `.exe`(ou `.jar`) na aba de releases do Logisim
2. Instale e execute o Logisim-Evolution

---

## 2) Abra o circuito do AX8 no Logisim-Evolution

Na raíz do repositório, abra o arquivo do circuito do projeto (`.circ`) no
Logisim Evolution.

Fluxo:

1. Inicie o Logisim-Evolution
2. `File -> Open`
3. Selecione o arquivo `ax8.circ`
4. Inspecione o modulo `TopLevel` e os subcircuitos
5. Utilize os controles de simulação (tick/clock/step) para inspecionar
   o comportamento

> o Logisim-Evolution é a parte principal do projeto, e sua validação é a
> fonte primária

---

## 3) Opcional: Verilog + GTKWave

O Makefile contido no projeto suporta a simulação de cada modulo verilog
individualmente por meio das Waveforms.

### Instale as ferramentas

#### Ubuntu/Debian

```bash
sudo apt update
sudo apt install -y iverilog gtkwave make
```

#### Fedora

```bash
sudo dnf install -y iverilog gtkwave make
```

#### Arch

```bash
sudo pacman -S --needed iverilog gtkwave make
```

#### Verifique

```bash
iverilog -V
vvp -V
gktwave --version
```

---

## 4) Makefile targets

### Construa e execute todos os modulos

`make all`

Esse comando gera:

- `build/<module>_sim`
- `build/<module>.vcd`

### Abra o waveform de um modulo

`make wave_<module>`

Exemplos:

```bash
make wave_cpu
make wave_alu
make wave_instruction_decoder
```

Isso garante que `build/<module>.vcd` exista, então abre-o com o GTKWave.

### Limpe os artefatos

`make clean`

---

## 5) Modulo disponíveis para `wave_<module>`

- `adder_subtractor`
- `alu`
- `cpu`
- `d_flipflop`
- `d_latch`
- `decode_arithmetic`
- `decode_jump`
- `decode_memory`
- `decode_system`
- `decode_unary`
- `flag_register`
- `full_adder`
- `instruction_decoder`
- `instruction_sequencer`
- `multiplier_4`
- `mux_2to1`
- `mux_4to1`
- `mux_8to1`
- `program_counter`
- `register_4`
- `register_8`
- `ripple_adder_4`
- `ripple_adder_8`
- `shifter_8`
- `toplevel`

---

## 6) Solução de problemas

### Logisim não inicia

- Verifique se o Java está instalado: <br>
  ```bash
  java -version
  ```

### `iverilog`/`gtkwave` não encontrado

- Instale os pacotes acima e verifique se estão no `PATH`

### `.vcd` não foi produzido

- Verifique se o TB tem `$dumpfile`/`$dumpvars`
- Tente novamente: <br>
  ```bash
  make clean
  make wave_<module>
  ```
