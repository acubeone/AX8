// AX8 - A simple 8-bit CPU inspired by the MOS6502
//
// Copyright (c) 2026 acubeone
// Email: acube_one@disroot.org
//
// This software is provided 'as-is', without any express or implied
// warranty. In no event will the authors be held liable for any damages
// arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software
//    in a product, an acknowledgment in the product documentation would be
//    appreciated but is not required.
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
// 3. This notice may not be removed or altered from any source
//    distribution.

#pragma once

#include "error.h"
#include "lexer.h"
#include "utils.h"

typedef enum StatementKind {
	STMT_CONST_DECL,
	STMT_LABEL_DECL,
	STMT_DIRECTIVE,
	STMT_INSTRUCTION,
} StatementKind;

typedef enum OperandMode {
	MODE_IMP, // Implied:   "IX" | "IY"
	MODE_IND, // Indirect:  "[IY]"
	MODE_IMM, // Immediate: "#" , constant
	MODE_ABS, // Absolute:  constant
	MODE_REF, // Reference: ":" , identifier
} OperandMode;

typedef enum DirectiveKind {
	DIR_ORG,   // .org
	DIR_DWORD, // .dword
	DIR_BYTE,  // .byte
	DIR_WORD,  // .word
} DirectiveKind;

typedef struct StmtOperand {
	OperandMode mode;

	union {
		u64 uval;	 // MODE_IMM, MODE_ABS
		i64 ival;	 // MODE_IMM, MODE_ABS
		char *label; // MODE_REF
	};
} StmtOperand;

typedef union DataValue {
	u32 uval;
	i32 ival;
} DataValue;

typedef struct StmtDirective {
	DirectiveKind kind;

	union {
		i32 address; // DIR_ORG

		struct { // DIR_BYTE (data_list: number | string)
			DataValue *items;
			usize count;
		} list;
	};
} StmtDirective;

typedef struct Statement {
	StatementKind kind;
	Position pos;

	union {
		struct {
			char *name;
			i64 value;
		} const_decl;

		char *label_name; // STMT_LABEL_DECL

		StmtDirective directive; // STMT_DIRECTIVE

		struct {
			TokenKind mnemonic;
			bool has_operand;
			StmtOperand operand;
		} instr;
	};
} Statement;

typedef struct ConstEntry {
	char *name;
	i64 value;
} ConstEntry;

typedef struct Parser {
	Token *tokens;
	usize count;
	usize pos;

	ConstEntry *consts;
	usize consts_count;
	usize consts_size;
} Parser;

ErrorCode parser_parse(Parser *p, Statement **out_stmts, usize *out_count);
