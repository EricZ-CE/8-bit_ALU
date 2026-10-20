# 8-bit CPU in Verilog

A small CPU built in Verilog to explore digital design, instruction decoding, and how a processor executes a program. The design uses an 8-bit datapath and a custom, fixed-width 8-bit instruction set.

The CPU has passed a self-checking integration test using Icarus Verilog on Windows and in GitHub Codespaces. FPGA implementation has not yet been tested.

## Features

- Six 8-bit registers, R0 through R5
- One 8-bit output register
- Seven ALU operations: addition, subtraction, AND, OR, XOR, left shift, and logical right shift
- Immediate loads, register transfers, and conditional jumps
- An 8-bit program counter and 256-byte program memory
- A programming interface for loading instructions
- Execution enable and synchronous, active-high reset

## Repository Layout

```text
.
├── CPU/
│   ├── ALU.v
│   ├── cond.v
│   ├── CPU.v
│   ├── ID.v
│   ├── memory.v
│   ├── PC.v
│   ├── register.v
│   └── RegisterFiles.v
├── CPU_tb.v
└── README.md
```

## Architecture

The program counter addresses program memory. The instruction decoder reads the two highest instruction bits to select the operation class. Combinational logic selects the operands, write destination, and next PC. Registers and the PC update on the rising clock edge.

With execution enabled, each instruction completes in one clock cycle in this RTL model. Program memory uses synchronous writes and asynchronous reads.

| Register | Role |
| --- | --- |
| R0 | Receives immediate values and supplies the jump target |
| R1 | ALU operand A |
| R2 | ALU operand B |
| R3 | Receives ALU results and supplies the value for branch comparisons |
| R4, R5 | General storage |
| OUT | Output register, accessed using register code `110` |

All six registers can also be read and written using MOV. OUT can be read back using MOV.

### CPU Interface

| Signal | Direction | Purpose |
| --- | --- | --- |
| `clk` | Input | Clock |
| `rst` | Input | Synchronous, active-high reset of PC, registers, and output |
| `enable` | Input | Enables instruction execution |
| `prog_we` | Input | Enables program-memory writes and blocks instruction execution |
| `prog_address[7:0]` | Input | Program-memory write address |
| `prog_data[7:0]` | Input | Instruction byte to write |
| `data_out[7:0]` | Output | Value held in the output register |
| `pc[7:0]` | Output | Current instruction address |
| `instruction[7:0]` | Output | Current memory read value |
| `R0[7:0]` through `R5[7:0]` | Output | Register values for observation and testing |

Execution is enabled when `enable && !prog_we && !rst` is true. While programming, `instruction` reflects the memory location selected by `prog_address`. Reset does not clear program memory, and `prog_we` can still write memory during reset.

## Instruction Set

Each instruction occupies one byte. The two highest bits select its class.

| Bits `[7:6]` | Format | Operation |
| --- | --- | --- |
| `00` | `00iiiiii` | Load a zero-extended 6-bit immediate into R0 |
| `01` | `01xxxooo` | Apply ALU operation `ooo` to R1 and R2, storing the result in R3 |
| `10` | `10sssddd` | Copy source register `sss` into destination `ddd` |
| `11` | `11xxxccc` | If condition `ccc` is true, set PC to R0 |

`x` marks an ignored bit in the encoding, not a Verilog unknown value. Use zero for these bits when writing programs.

### ALU Operations

| `ooo` | Operation | Result written to R3 |
| --- | --- | --- |
| `000` | ADD | R1 + R2 |
| `001` | SUB | R1 - R2 |
| `010` | AND | R1 & R2 |
| `011` | OR | R1 \| R2 |
| `100` | XOR | R1 ^ R2 |
| `101` | SHL | R1 shifted left by one bit |
| `110` | SHR | R1 shifted right logically by one bit |
| `111` | Default | Zero |

Results are truncated to 8 bits. Addition and subtraction wrap modulo 256; there are no carry or overflow flags. Shifts ignore R2. The ALU produces a zero signal, but CPU branch decisions compare R3 directly.

### Register Codes

| Code | Register |
| --- | --- |
| `000` | R0 |
| `001` | R1 |
| `010` | R2 |
| `011` | R3 |
| `100` | R4 |
| `101` | R5 |
| `110` | OUT |
| `111` | Unassigned: reads return zero, writes have no effect |

### Branch Conditions

Conditions interpret R3 as an 8-bit signed two's-complement value, from -128 to 127. A taken branch uses the full 8-bit value in R0 as its target. Otherwise, PC increments by one.

| `ccc` | Condition |
| --- | --- |
| `000` | Never jump |
| `001` | Always jump |
| `010` | R3 == 0 |
| `011` | R3 != 0 |
| `100` | R3 < 0 |
| `101` | R3 >= 0 |
| `110` | R3 <= 0 |
| `111` | R3 > 0 |

## Example Program

This example computes 5 + 3, writes 8 to OUT, and enters a loop.

The mnemonic notation below is explanatory. An assembler is not included; the current testbench loads instruction bytes through the programming interface. MOV notation places the destination first.

| Address | Hex byte | Mnemonic notation | Effect |
| --- | --- | --- | --- |
| 0 | `05` | LDI 5 | R0 = 5 |
| 1 | `81` | MOV R1, R0 | R1 = 5 |
| 2 | `03` | LDI 3 | R0 = 3 |
| 3 | `82` | MOV R2, R0 | R2 = 3 |
| 4 | `40` | ADD | R3 = 8 |
| 5 | `9E` | MOV OUT, R3 | OUT = 8 |
| 6 | `07` | LDI 7 | R0 = 7 |
| 7 | `C1` | JMP | PC = 7, forming a self-loop |

This short example is separate from the longer program in `CPU_tb.v`.

## Run the Integration Test

### GitHub Codespaces / Ubuntu

Install Icarus Verilog:

```bash
sudo apt-get update
sudo apt-get install -y iverilog
```

From the repository root, compile and run:

```bash
iverilog -g2012 -Wall -s CPU_tb -o cpu_sim CPU/*.v CPU_tb.v && vvp cpu_sim
```

### Windows PowerShell

With Icarus Verilog available on PATH, run from the repository root:

```powershell
iverilog -g2012 -Wall -s CPU_tb -o cpu_sim CPU/CPU.v CPU/ALU.v CPU/cond.v CPU/ID.v CPU/memory.v CPU/PC.v CPU/register.v CPU/RegisterFiles.v CPU_tb.v
```

If compilation succeeds:

```powershell
vvp .\cpu_sim
```

### Expected Result

```text
All CPU tests passed! (33 state checks + 32 program readbacks)
```

The testbench compares expected and actual values after rising clock edges, allowing nonblocking assignments to settle before checking. A mismatch calls `$fatal` and stops the simulation.

| Tested behavior | What is checked |
| --- | --- |
| Reset | PC, all six registers, and OUT clear to zero |
| Program loading | 32 instruction bytes read back correctly; execution is blocked during programming |
| Immediate loads and MOV | Expected values reach their destination registers |
| ALU integration | All seven ALU operations produce the expected register results in the test program |
| Output register | Writes and retained values match expectations |
| Pause | Architectural state holds when execution is disabled |
| Branching | Zero/nonzero conditions, taken and untaken branches, always/never conditions, and a self-loop |

Each of the 33 state checks compares PC, R0 through R5, and OUT. The console prints only PC, R3, and OUT to keep the log readable.

### Waveforms

The testbench generates `CPU_tb.vcd`. On a computer with GTKWave installed and a graphical desktop, open it with:

```bash
gtkwave CPU_tb.vcd
```

For a Codespaces run, download the VCD file and open it locally. Useful signals include `clk`, `rst`, `enable`, `prog_we`, `pc`, `instruction`, R0 through R5, and `data_out`.

## Current Limitations

- The integration test covers a selected program, not every instruction/input combination.
- Signed branch conditions, PC wraparound, and additional arithmetic boundaries need further integration tests.
- Immediate values are limited to 0-63. Higher register values can be constructed with ALU operations and MOV.
- ALU operands and the result register are fixed to R1, R2, and R3.
- There are no CPU data-memory load/store instructions, stack, interrupts, or dedicated HALT instruction.
- Program memory must be loaded before execution; unwritten locations are uninitialized in simulation.
- The design has not been validated through FPGA implementation or timing analysis.

## Next Steps

- Expand test coverage for boundary values and all signed branch conditions
- Add an assembler with labels and input validation
- Run integration tests automatically with GitHub Actions
- Explore synthesis and an FPGA demonstration

## Acknowledgments

ChatGPT assisted with debugging, testbench development, and documentation. The instruction-set choices and CPU behavior are documented above so the implementation and its current verification scope can be reviewed.
