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

#include "error.h"
#include "lexer.h"

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
	atexit(err_flush);

	FILE *file = stdin;

	if (argc > 1) {
		file = fopen(argv[1], "rb");
		if (!file)
			log_warn("Failed to open file at '%s'... reading from STDIN", argv[1]);
	}

	LexerState lex;
	lex_init(&lex, file);

	Token tk = { .kind = TK_NONE, .pos = {} };
	while (tk.kind != TK_EOF) {
		ErrorCode err = lex_scan(&lex, &tk);
		if (err)
			break;

		if (tk.kind <= TK_LAST_SYMBOL)
			printf("%zu:%zu -> %s\n", tk.pos.lineno, tk.pos.colno, lex_tok2str(tk.kind));

		if (tk.kind == TK_NUMBER)
			printf("%zu:%zu -> %hu\n", tk.pos.lineno, tk.pos.colno, tk.number);

		if (tk.kind == TK_IDENTIFIER && tk.ident) {
			printf("%zu:%zu -> %s\n", tk.pos.lineno, tk.pos.colno, tk.ident);

			free(tk.ident);
			tk.ident = nullptr;
		}

		if (tk.kind == TK_STRING && tk.str.ptr) {
			printf("%zu:%zu -> %s\n", tk.pos.lineno, tk.pos.colno, tk.str.ptr);

			free(tk.str.ptr);
			tk.str.ptr = nullptr;
		}

		err_flush();
	}

	lex_close(&lex);
	return EXIT_SUCCESS;
}
