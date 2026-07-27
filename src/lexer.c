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

#include "lexer.h"

#include "error.h"
#include "utils.h"

#include <assert.h>
#include <ctype.h>
#include <errno.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32) || defined(_WIN64)
#	define strcasecmp	_stricmp
#	define strncasecmp _strnicmp
#else
#	include <strings.h>
#endif

enum {
	NUL_CHAR = '\0',
	EOF_CHAR = UINT32_MAX,
	MAX_CHAR_BUF = 4,
};

// clang-format off
static const char *const _token_names[] = {
	// Keywords (MUST BE SORTED!)
	[TK_BYTE] = ".BYTE",
	[TK_DWORD] = ".DWORD",
	[TK_ORG] = ".ORG",
	[TK_WORD] = ".WORD",
	[TK_ADC] = "ADC",
	[TK_AND] = "AND",
	[TK_BCC] = "BCC",
	[TK_BCS] = "BCS",
	[TK_BEQ] = "BEQ",
	[TK_BMI] = "BMI",
	[TK_BNE] = "BNE",
	[TK_BPL] = "BPL",
	[TK_BRA] = "BRA",
	[TK_BVC] = "BVC",
	[TK_BVS] = "BVS",
	[TK_CLC] = "CLC",
	[TK_CLV] = "CLV",
	[TK_CMP] = "CMP",
	[TK_DEC] = "DEC",
	[TK_DEX] = "DEX",
	[TK_DEY] = "DEY",
	[TK_HLT] = "HLT",
	[TK_INC] = "INC",
	[TK_INX] = "INX",
	[TK_INY] = "INY",
	[TK_IX] = "IX",
	[TK_IY] = "IY",
	[TK_JMP] = "JMP",
	[TK_LD] = "LD",
	[TK_LDI] = "LDI",
	[TK_LDX] = "LDX",
	[TK_LDY] = "LDY",
	[TK_MUL] = "MUL",
	[TK_NOP] = "NOP",
	[TK_NOT] = "NOT",
	[TK_OR] = "OR",
	[TK_ROL] = "ROL",
	[TK_ROR] = "ROR",
	[TK_SEC] = "SEC",
	[TK_SEV] = "SEV",
	[TK_ST] = "ST",
	[TK_STX] = "STX",
	[TK_STY] = "STY",
	[TK_SBC] = "SBC",
	[TK_SHL] = "SHL",
	[TK_SHR] = "SHR",
	[TK_TAX] = "TAX",
	[TK_TAY] = "TAY",
	[TK_TXA] = "TXA",
	[TK_TXY] = "TXY",
	[TK_TYA] = "TYA",
	[TK_TYX] = "TYX",
	[TK_XOR] = "XOR",

	// Symbols
	[TK_COLLON] = ":",
	[TK_COMMA] = ",",
	[TK_EQUAL] = "=",
	[TK_HASH] = "#",
	[TK_LBRACKET] = "[",
	[TK_MINUS] = "-",
	[TK_PLUS] = "+",
	[TK_RBRACKET] = "]",
};
// clang-format on

static_assert(
	sizeof(_token_names) / sizeof(const char *) == (TK_LAST_SYMBOL + 1),
	"_token_names array doesn't have the same size as TokenKind enum."
);

static inline bool _is_space(u32 c) {
	return c == ' ' || c == '\t' || c == '\n';
}

static int _keyword_cmp(const void *v1, const void *v2) {
	return strcasecmp(*(const char **)v1, *(const char **)v2);
}

static void _update_pos(Position *pos, u32 c) {
	if (c == '\n') { // Update line, reset column
		pos->lineno += 1;
		pos->colno = 0;
	} else {
		pos->colno += 1;
	}
}

static void _stack_push(LexerState *lex, u32 c, bool frombuf) {
	assert(lex->stack[1] == EOF_CHAR);

	lex->stack[1] = lex->stack[0];
	lex->stack[0] = c;

	if (frombuf) { // Character was from buffer, consume it
		lex->buflen -= 1;
		lex->buf[lex->buflen] = '\0';
	}
}

static void _buffer_insert(LexerState *lex, const char *str, usize size) {
	if (lex->buflen + size >= lex->bufsize) {
		lex->bufsize *= 1.5;
		char *tmp = REALLOC(lex->buf, lex->bufsize);
		if (!tmp)
			log_fatal(ERR_OUT_OF_MEMORY, "Failed to reallocate buffer");
		lex->buf = tmp;
	}

	memcpy(&lex->buf[lex->buflen], str, size);
	lex->buflen += size;
	lex->buf[lex->buflen] = '\0';
}

static void _buffer_clear(LexerState *lex) {
	lex->buflen = 0;
	lex->buf[0] = '\0';
}

static u32 _fetch_char(LexerState *lex, Position *pos, bool buffer) {
	u32 c;

	if (lex->stack[0] != EOF_CHAR) {
		c = lex->stack[0];
		lex->stack[0] = lex->stack[1];
		lex->stack[1] = EOF_CHAR;
	} else {
		c = fgetc(lex->file);
		_update_pos(&lex->pos, c);

		if (feof(lex->file)) {
			c = EOF_CHAR;
		} else if (c == NUL_CHAR) {
			_PUSH_ERROR((*pos), ERR_IO, "Null-terminator found before end-of-file");
		}
	}

	if (pos != nullptr) {
		*pos = lex->pos;

		if (lex->stack[0] != EOF_CHAR)
			_update_pos(&lex->pos, lex->stack[0]);
		if (lex->stack[1] != EOF_CHAR)
			_update_pos(&lex->pos, lex->stack[1]);
	}

	// Do we need to store in buffer?
	if (buffer && c != '\0') {
		_buffer_insert(lex, (char *)&c, 1);
	}

	return c;
}

static u32 _trim_spaces(LexerState *lex, Position *pos) {
	u32 c = ' ';

	while (c != NUL_CHAR && _is_space(c))
		c = _fetch_char(lex, pos, false);

	return c;
}

static ErrorCode _lex_number(LexerState *lex, Token *tk) {
	enum NumberBase : u8 {
		B_BIN = 1 << 0,		   // Binary
		B_HEX = 1 << 1,		   // Hexadecimal
		B_DEC = B_BIN | B_HEX, // Decimal
		B_MASK = B_DEC,
	};

	enum StateFlag : u8 {
		F_SYM = 1 << 3, // Is Symbol
		F_SEP = 1 << 4, // Is Separator
	};

	static const char *digits[] = {
		[B_BIN] = "01",
		[B_HEX] = "0123456789abcdefABCDEF",
		[B_DEC] = "0123456789",
	};

	u32 c = _fetch_char(lex, &tk->pos, true);
	assert(c != NUL_CHAR && c <= 0x7f && (isdigit(c) || c == '$' || c == '%'));

	u8 state = B_DEC;
	u8 base = 10;

	if (c == '%') { // Binary
		state = B_BIN | F_SYM;
		base = 2;
	} else if (c == '$') { // Hexadecimal
		state = B_HEX | F_SYM;
		base = 16;
	}

	// If it is not a decimal, we skip symbol and fetch next character
	if (state != B_DEC)
		c = _fetch_char(lex, nullptr, true);

	while (c != NUL_CHAR) {
		if (strchr(digits[state & B_MASK], (i32)c)) {
			state &= ~(F_SYM | F_SEP); // It is not a Symbol neither a Separator
			c = _fetch_char(lex, nullptr, true);
			continue;
		}

		if (state & F_SEP)
			_PUSH_ERROR(
				tk->pos, ERR_LEX_EXPECTED_DIGIT, "Expected digit, found: '%c'", c
			);

		if (c != '_')
			break; // If it is not a separator, then we found the end

		state |= F_SYM | F_SEP;

		// Consume character
		lex->buflen -= 1;
		lex->buf[lex->buflen] = '\0';
		c = _fetch_char(lex, nullptr, true);
	}

	// Push back not digit character back into the stack
	if (c != NUL_CHAR)
		_stack_push(lex, c, true);

	errno = 0;
	tk->kind = TK_NUMBER;
	tk->number = strtoumax(&lex->buf[base == 10 ? 0 : 1], nullptr, base);
	if (errno == ERANGE)
		_PUSH_ERROR(tk->pos, ERR_GENERIC, "Integer overflow!");

	_buffer_clear(lex);
	return ERR_SUCCESS;
}

static ErrorCode _lex_identifier(LexerState *lex, Token *tk) {
	u32 c = _fetch_char(lex, &tk->pos, true);
	assert(c != NUL_CHAR && c <= 0x7f && (isalpha(c) || c == '_' || c == '.'));

	if (c == '.') // Consume '.' for directives
		c = _fetch_char(lex, nullptr, true);

	while (c != NUL_CHAR) {
		if (!isalnum(c) && c != '_') {
			_stack_push(lex, c, true);
			break;
		}

		c = _fetch_char(lex, nullptr, true);
	}

	const char **token_name = (const char **)bsearch(
		(const void *)&lex->buf, (const void *)_token_names, TK_LAST_KEYWORD + 1,
		sizeof(_token_names[0]), _keyword_cmp
	);

	if (token_name) {
		tk->kind = token_name - _token_names;
	} else {
		tk->kind = TK_IDENTIFIER;
		tk->ident = strndup(lex->buf, lex->buflen);
	}

	_buffer_clear(lex);
	return ERR_SUCCESS;
}

static ErrorCode _lex_character(LexerState *lex, char *out) {
	u32 c = _fetch_char(lex, nullptr, false);
	assert(c != NUL_CHAR);

	if (c == '\\') { // It's a escape sequence
		Position pos = lex->pos;
		c = _fetch_char(lex, nullptr, false);

		switch (c) {
		case 'n':  *out = '\n'; break;
		case 'r':  *out = '\r'; break;
		case 't':  *out = '\t'; break;
		case '\'': *out = '\''; break;
		case '"':  *out = '\"'; break;
		case '\\': *out = '\\'; break;
		case '0':  *out = '\0'; break;
		case 'x':  {
			char buf[3] = {};
			char *endptr = nullptr;

			buf[0] = (char)_fetch_char(lex, nullptr, false);
			buf[1] = (char)_fetch_char(lex, nullptr, false);
			buf[2] = '\0';

			*out = (u8)strtoul(buf, &endptr, 16);
			if (*endptr != '\0')
				_PUSH_ERROR(pos, ERR_LEX_INVALID, "Invalid hex escape sequence");
		} break;
		case NUL_CHAR: _PUSH_ERROR(pos, ERR_LEX_EOF, "Unexpected end-of-file");
		default:	   _PUSH_ERROR(pos, ERR_LEX_EOF, "Invalid escape sequence");
		}

		return ERR_SUCCESS;
	}

	// Just a normal character
	*out = c;
	return ERR_SUCCESS;
}

static ErrorCode _lex_string(LexerState *lex, Token *tk) {
	u32 c = _fetch_char(lex, &tk->pos, false);

	switch (c) {
	case '"': // Scan string
		c = _fetch_char(lex, nullptr, false);
		while (c != '"') {
			if (c == NUL_CHAR)
				_PUSH_ERROR(tk->pos, ERR_LEX_EOF, "Unexpected end-of-file");

			char chr;
			_stack_push(lex, c, false);
			ErrorCode err = _lex_character(lex, &chr);
			if (err)
				return err;
			_buffer_insert(lex, &chr, 1);

			c = _fetch_char(lex, nullptr, false);
		}

		tk->kind = TK_STRING;
		tk->str.len = lex->buflen;
		tk->str.ptr = strndup(lex->buf, lex->buflen);

		_buffer_clear(lex);
		break;
	case '\'':
		c = _fetch_char(lex, nullptr, false);

		if (c == '\'')
			_PUSH_ERROR(
				tk->pos, ERR_LEX_INVALID, "Expected character before closing single-quote"
			);

		_stack_push(lex, c, false);
		char chr;
		ErrorCode err = _lex_character(lex, &chr);
		if (err)
			return err;

		c = _fetch_char(lex, nullptr, false);
		if (c != '\'')
			_PUSH_ERROR(tk->pos, ERR_LEX_INVALID, "Expected closing single-quote");

		tk->kind = TK_NUMBER;
		tk->number = (i64)chr;
		break;
	default: unreachable();
	}

	return ERR_SUCCESS;
}

void lex_init(LexerState *lex, FILE *file) {
	assert(lex);
	assert(file);

	memset(lex, 0, sizeof(LexerState));

	lex->file = file;
	lex->pos.lineno = 1;
	lex->pos.colno = 1;

	lex->stack[0] = EOF_CHAR;
	lex->stack[1] = EOF_CHAR;

	lex->bufsize = 128;
	lex->buf = ALLOC(lex->bufsize * sizeof(char));
}

void lex_close(LexerState *lex) {
	assert(lex);

	FREE(lex->buf);
}

ErrorCode lex_scan(LexerState *lex, Token *tk) {
	assert(lex);

	u32 c = _trim_spaces(lex, &tk->pos);
	if (c == EOF_CHAR) {
		tk->kind = TK_EOF;
		return ERR_LEX_EOF;
	}

	if (c >= 0x80) {
		log_warn("Invalid ASCII character!");
		tk->kind = TK_NONE;
		return ERR_LEX_INVALID;
	}

	// Strip all comment from file
	if (c == ';') {
		while (c != NUL_CHAR && c != '\n')
			c = _fetch_char(lex, nullptr, false);

		return lex_scan(lex, tk); // Search for a valid token
	}

	if (isdigit(c) || c == '$' || c == '%') {
		_stack_push(lex, c, false);
		return _lex_number(lex, tk);
	}

	if (isalnum(c) || c == '_' || c == '.') {
		_stack_push(lex, c, false);
		return _lex_identifier(lex, tk);
	}

	switch (c) {
	case '"':
	case '\'': //
		_stack_push(lex, c, false);
		return _lex_string(lex, tk);
	case ':': tk->kind = TK_COLLON; break;
	case ',': tk->kind = TK_COMMA; break;
	case '=': tk->kind = TK_EQUAL; break;
	case '#': tk->kind = TK_HASH; break;
	case '[': tk->kind = TK_LBRACKET; break;
	case '-': tk->kind = TK_MINUS; break;
	case '+': tk->kind = TK_PLUS; break;
	case ']': tk->kind = TK_RBRACKET; break;
	default:  _PUSH_ERROR(lex->pos, ERR_LEX_INVALID, "Unknown symbol found: %c", c);
	}

	return ERR_SUCCESS;
}

const char *lex_tok2str(TokenKind kind) {
	assert(kind <= TK_LAST_SYMBOL);
	return _token_names[kind];
}
