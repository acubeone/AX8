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
#include "utils.h"

#include <stdio.h>

typedef enum TokenKind {
	// Keywords
	TK_BYTE,  // .BYTE
	TK_DWORD, // .DWORD
	TK_ORG,	  // .ORG
	TK_WORD,  // .WORD
	TK_ADC,
	TK_AND,
	TK_BCC,
	TK_BCS,
	TK_BEQ,
	TK_BMI,
	TK_BNE,
	TK_BPL,
	TK_BRA,
	TK_BVC,
	TK_BVS,
	TK_CLC,
	TK_CLV,
	TK_CMP,
	TK_DEC,
	TK_DEX,
	TK_DEY,
	TK_HLT,
	TK_INC,
	TK_INX,
	TK_INY,
	TK_IX,
	TK_IY,
	TK_JMP,
	TK_LD,
	TK_LDI,
	TK_LDX,
	TK_LDY,
	TK_MUL,
	TK_NOP,
	TK_NOT,
	TK_OR,
	TK_ROL,
	TK_ROR,
	TK_SEC,
	TK_SEV,
	TK_ST,
	TK_STX,
	TK_STY,
	TK_SBC,
	TK_SHL,
	TK_SHR,
	TK_TAX,
	TK_TAY,
	TK_TXA,
	TK_TXY,
	TK_TYA,
	TK_TYX,
	TK_XOR,
	TK_LAST_KEYWORD = TK_XOR,

	// Symbols
	TK_COLLON,	 // :
	TK_COMMA,	 // ,
	TK_EQUAL,	 // =
	TK_HASH,	 // #
	TK_LBRACKET, // [
	TK_MINUS,	 // -
	TK_PLUS,	 // +
	TK_RBRACKET, // ]
	TK_LAST_SYMBOL = TK_RBRACKET,

	// Data
	TK_NUMBER,
	TK_STRING,
	TK_IDENTIFIER,

	TK_NONE,
	TK_EOF,
} TokenKind;

typedef struct Token {
	TokenKind kind;
	Position pos;

	union {
		char *ident;
		u64 number;

		struct {
			usize len;
			char *ptr;
		} str;
	};
} Token;

typedef struct LexerState {
	FILE *file;
	Position pos;

	u32 stack[2]; // Character stack
	usize buflen;
	usize bufsize;
	char *buf;
} LexerState;

void lex_init(LexerState *lex, FILE *file);
void lex_close(LexerState *lex);

ErrorCode lex_scan(LexerState *lex, Token *tk);

const char *lex_tok2str(TokenKind kind);
