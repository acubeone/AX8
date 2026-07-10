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
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define _PUSH_ERROR(pos, code, ...)                                             \
	{                                                                           \
		log_error(code, "At %zu:%zu - %s", pos.lineno, pos.colno, __VA_ARGS__); \
		return code;                                                            \
	}

enum {
	EOF_CHAR = '\0',
	INVALID_CHAR = UINT32_MAX,
	MAX_CHAR_BUF = 4,
};

static void update_pos(Position *pos, u32 c) {
	if (c == '\n') { // Update line, reset column
		pos->lineno += 1;
		pos->colno = 0;
	} else {
		pos->colno += 1;
	}
}

static void stack_push(LexerState *lex, u32 c, bool frombuf) {
	assert(lex->stack[1] == INVALID_CHAR);

	lex->stack[1] = lex->stack[0];
	lex->stack[0] = c;

	if (frombuf) { // Character was from buffer, consume it
		lex->buflen -= 1;
		lex->buf[lex->buflen] = '\0';
	}
}

static void buffer_insert(LexerState *lex, const char *str, usize size) {
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

static void buffer_clear(LexerState *lex) {
	lex->buflen = 0;
	lex->buf[0] = '\0';
}

static u32 next_char(LexerState *lex, Position *pos, bool buffer) {
	u32 c;

	if (lex->stack[0] != INVALID_CHAR) {
		c = lex->stack[0];
		lex->stack[0] = lex->stack[1];
		lex->stack[1] = INVALID_CHAR;
	} else {
		c = fgetc(lex->file);
		update_pos(&lex->pos, c);

		if (c == INVALID_CHAR && !feof(lex->file))
			_PUSH_ERROR((*pos), ERR_IO, "Null-terminator found before end-of-file");
	}

	if (pos != nullptr) {
		*pos = lex->pos;

		if (lex->stack[0] != INVALID_CHAR)
			update_pos(&lex->pos, lex->stack[0]);
		if (lex->stack[1] != INVALID_CHAR)
			update_pos(&lex->pos, lex->stack[1]);
	}

	// Do we need to store in buffer?
	if (buffer && c != '\0') {
		buffer_insert(lex, (char *)&c, 1);
	}

	return c;
}

static inline bool is_space(u32 c) {
	return c == ' ' || c == '\t' || c == '\n';
}

static u32 trimspaces(LexerState *lex, Position *pos) {
	u32 c = ' ';

	while (c != EOF_CHAR && is_space(c)) {
		c = next_char(lex, pos, false);
	}

	return c;
}

static ErrorCode lex_character(LexerState *lex, char *out) {
	u32 c = next_char(lex, nullptr, false);
	assert(c != EOF_CHAR);

	if (c == '\\') { // It's a escape sequence
		Position pos = lex->pos;
		c = next_char(lex, nullptr, false);

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

			buf[0] = (char)next_char(lex, nullptr, false);
			buf[1] = (char)next_char(lex, nullptr, false);
			buf[2] = '\0';

			*out = (u8)strtoul(buf, &endptr, 16);
			if (*endptr != '\0')
				_PUSH_ERROR(pos, ERR_LEX_INVALID, "Invalid hex escape sequence");
		} break;
		case EOF_CHAR: _PUSH_ERROR(pos, ERR_LEX_EOF, "Unexpected end-of-file");
		default:	   _PUSH_ERROR(pos, ERR_LEX_EOF, "Invalid escape sequence");
		}

		return ERR_SUCCESS;
	}

	// Just a normal character
	*out = c;
	return ERR_SUCCESS;
}

static ErrorCode lex_string(LexerState *lex, Token *tk) {
	u32 c = next_char(lex, &tk->pos, false);

	switch (c) {
	case '"': // Scan string
		c = next_char(lex, nullptr, false);
		while (c != '"') {
			if (c == EOF_CHAR)
				_PUSH_ERROR(tk->pos, ERR_LEX_EOF, "Unexpected end-of-file");

			char chr;
			stack_push(lex, c, false);
			ErrorCode err = lex_character(lex, &chr);
			if (err)
				return err;
			buffer_insert(lex, &chr, 1);

			c = next_char(lex, nullptr, false);
		}

		tk->kind = TK_STRING;
		tk->str.len = lex->buflen;
		tk->str.ptr = strndup(lex->buf, lex->buflen);

		buffer_clear(lex);
		break;
	case '\'':
		c = next_char(lex, nullptr, false);

		if (c == '\'')
			_PUSH_ERROR(
				tk->pos, ERR_LEX_INVALID, "Expected character before closing single-quote"
			);

		stack_push(lex, c, false);
		char chr;
		ErrorCode err = lex_character(lex, &chr);
		if (err)
			return err;

		c = next_char(lex, nullptr, false);
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

	lex->stack[0] = INVALID_CHAR;
	lex->stack[1] = INVALID_CHAR;

	lex->bufsize = 128;
	lex->buf = ALLOC(lex->bufsize * sizeof(char));
}

void lex_close(LexerState *lex) {
	assert(lex);

	FREE(lex->buf);
}

ErrorCode lex_scan(LexerState *lex, Token *tk) {
	assert(lex);

	u32 c = trimspaces(lex, &tk->pos);
	if (c == EOF_CHAR) {
		tk->kind = TK_EOF;
		return ERR_LEX_EOF;
	}

	if (c >= 0x80) {
		log_warn("Invalid ASCII character!");
		tk->kind = TK_NONE;
		return ERR_LEX_INVALID;
	}

	switch (c) {
	case '"':
	case '\'': {
		stack_push(lex, c, false);
		return lex_string(lex, tk);
	}
	}

	return ERR_GENERIC;
}
