from typing import Optional, Literal

AddrMode = Literal["IMP", "IND", "IMM", "ABS", "REL"]
Opcode = Optional[int]
OpEntry = dict[AddrMode, Opcode]
OpTable = dict[str, OpEntry]

MODE_SIZE = dict[AddrMode, int] = {
    "IMP": 1,
    "IND": 1,
    "IMM": 2,
    "ABS": 3,
    "REL": 2,
}

# fmt: off
OP_TABLE: OpTable = {
    # Group 000: System
    "NOP": {"IMP": 0x00, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "CLC": {"IMP": 0x04, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "SEC": {"IMP": 0x05, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "CLV": {"IMP": 0x06, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "SEV": {"IMP": 0x07, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "HLT": {"IMP": 0x1F, "IND": None, "IMM": None, "ABS": None, "REL": None},

    # Group 001: Memory
    "LD":  {"IMP": None, "IND": 0x28, "IMM": None, "ABS": 0x20, "REL": None},
    "LDX": {"IMP": None, "IND": 0x29, "IMM": None, "ABS": 0x21, "REL": None},
    "LDY": {"IMP": None, "IND": 0x2A, "IMM": None, "ABS": 0x22, "REL": None},
    "ST":  {"IMP": None, "IND": 0x2C, "IMM": None, "ABS": 0x24, "REL": None},
    "STX": {"IMP": None, "IND": 0x2D, "IMM": None, "ABS": 0x25, "REL": None},
    "STY": {"IMP": None, "IND": 0x2E, "IMM": None, "ABS": 0x26, "REL": None},
    "TAA": {"IMP": 0x30, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "TAX": {"IMP": 0x31, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "TAY": {"IMP": 0x32, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "TXA": {"IMP": 0x34, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "TXX": {"IMP": 0x35, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "TXY": {"IMP": 0x36, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "TYA": {"IMP": 0x37, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "TYX": {"IMP": 0x38, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "TYY": {"IMP": 0x39, "IND": None, "IMM": None, "ABS": None, "REL": None},

    # Group 010: Arithmetic
    "ADC": {"IMP": 0x40, "IND": 0x48, "IMM": 0x50, "ABS": 0x58, "REL": None},
    "SBC": {"IMP": 0x41, "IND": 0x49, "IMM": 0x51, "ABS": 0x59, "REL": None},
    "MUL": {"IMP": 0x42, "IND": 0x4A, "IMM": 0x52, "ABS": 0x5A, "REL": None},
    "AND": {"IMP": 0x43, "IND": 0x4B, "IMM": 0x53, "ABS": 0x5B, "REL": None},
    "OR":  {"IMP": 0x44, "IND": 0x4C, "IMM": 0x54, "ABS": 0x5C, "REL": None},
    "XOR": {"IMP": 0x45, "IND": 0x4D, "IMM": 0x55, "ABS": 0x5D, "REL": None},
    "CMP": {"IMP": 0x46, "IND": 0x4E, "IMM": 0x56, "ABS": 0x5E, "REL": None},
    "LDI": {"IMP": None, "IND": None, "IMM": 0x57, "ABS": None, "REL": None},

    # Group 011: Unary
    "SHL": {"IMP": 0x60, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "SHR": {"IMP": 0x61, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "NOT": {"IMP": 0x65, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "ROL": {"IMP": 0x66, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "ROR": {"IMP": 0x67, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "INC": {"IMP": 0x68, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "INX": {"IMP": 0x69, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "INY": {"IMP": 0x6a, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "DEC": {"IMP": 0x6c, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "DEX": {"IMP": 0x6d, "IND": None, "IMM": None, "ABS": None, "REL": None},
    "DEY": {"IMP": 0x6e, "IND": None, "IMM": None, "ABS": None, "REL": None},

    # Group 100: Jump
    "BNQ": {"IMP": None, "IND": None, "IMM": None, "ABS": None, "REL": 0x80},
    "BPL": {"IMP": None, "IND": None, "IMM": None, "ABS": None, "REL": 0x81},
    "BCC": {"IMP": None, "IND": None, "IMM": None, "ABS": None, "REL": 0x82},
    "BVC": {"IMP": None, "IND": None, "IMM": None, "ABS": None, "REL": 0x83},
    "BEQ": {"IMP": None, "IND": None, "IMM": None, "ABS": None, "REL": 0x84},
    "BMI": {"IMP": None, "IND": None, "IMM": None, "ABS": None, "REL": 0x85},
    "BCS": {"IMP": None, "IND": None, "IMM": None, "ABS": None, "REL": 0x86},
    "BVS": {"IMP": None, "IND": None, "IMM": None, "ABS": None, "REL": 0x87},
    "BRA": {"IMP": None, "IND": None, "IMM": None, "ABS": None, "REL": 0x90},
    "JMP": {"IMP": None, "IND": None, "IMM": None, "ABS": 0x91, "REL": None},
}
# fmt: on
