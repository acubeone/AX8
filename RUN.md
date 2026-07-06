# RUN

AX8 is primarily inspected with Logisim-Evolution. <br>
Verilog simulation and inspection is also possible with the Makefile.

## 1) Install Logisim-Evolution (Primary workflow)

Logisim-Evolution releases: https://github.com/logisim-evolution/logisim-evolution/releases

### Linux

1. Install Java (JRE 11+ recommended)
2. Download the `.jar` from releases tab
3. Run:

```bash
java -jar logisim-evolution-*.jar
```

### Windows

1. Download `.exe` installer (or `.jar`) from releases tab
2. Install and run Logisim-Evolution

---

## 2) Open the AX8 circuit in Logisim-Evolution

From repo root, open the project circuit file (`.circ`) in Logisim-Evolution.

Flow:

1. Start Logisim-Evolution
2. `File -> Open`
3. Select `ax8.circ` file
4. Inspect the `TopLevel` and subcircuits
5. Use the simulation controls (tick/clock/step) for behaviour inspection

> Logisim-Evolution is the main part of the project, and your validation is
> the primary source

---

## 3) Optional: Verilog + GTKWave

The Makefile in this project supports each verilog module individual simulation
using Waveforms.

### Install tools

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

#### Build and run all modules

```bash
make all
```

This commands generates:

1. `build/<module>_sim`
2. `build/<module>.vcd`

#### Open the waveform of a module

```bash
make wave_<module>
```

Examples:

```bash
make wave_cpu
make wave_alu
make wave_instruction_decoder
```

This ensures `build/<module>.vcd` exists, then opens it with GTKWave.

#### Clean artifacts

```bash
make clean
```

## 5) Available modules for `wave_<module>`

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

## 6) Troubleshooting

### Logisim-Evolution won't start

- Verify Java is installed: <br>
  ```bash
  java -version
  ```

### `iverilog`/`gtkwave` not found

- Install packages above and verify they are in `PATH`

### `.vcd` isn't generated

- Verify that TB has `$dumpfile`/`$dumpvars`
- Try again: <br>
  ```bash
  make clean
  make wave_<module>
  ```
