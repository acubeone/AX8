// AX8 - A simple 8-bit CPU inspired by the MOS6502
// Copyright (C) 2026  aCube
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, see
// <https://www.gnu.org/licenses/>.

#include "error.h"

#include "basic_types.h"

#include <assert.h>
#include <stdarg.h>
#include <stdio.h>
#include <time.h>

typedef struct ErrorContext {
	usize stack_top;
	ErrorEntry stack[ERR_MAX_STACK_DEPTH];
	FILE *stream;
} ErrorContext;

static ErrorSeverity _min_severity = SEVERITY_INFO;
static _Thread_local struct ErrorContext _ctx = {};

static const char *const _severity_name[] = {
	"INFO",
	"WARN",
	"ERROR",
	"FATAL",
};

static const char *const _severity_color[] = {
	"\x1b[36m",
	"\x1b[33m",
	"\x1b[31m",
	"\x1b[35m",
};

void err_flush(void) {
	if (_ctx.stack_top == 0)
		return;

	FILE *out = _ctx.stream ? _ctx.stream : stderr;

	fprintf(out, "\n[ASM] > Error Stack Dump:\n");
	fprintf(out, "================\n");

	for (usize i = 0; i < _ctx.stack_top; i += 1) {
		ErrorEntry *entry = &_ctx.stack[i];

		struct tm *ltime = localtime(&entry->timestamp);
		char timestamp_buf[16] = {};
		timestamp_buf[strftime(timestamp_buf, 16, "%T", ltime)] = '\0';

		const char *sev_name = _severity_name[entry->severity];
		const char *sev_color = _severity_color[entry->severity];

		fprintf(
			out, "#%02zu - [%s] %s%s\x1b[0m (%#02x)\n", i,
			timestamp_buf[0] ? timestamp_buf : "no-time", sev_color, sev_name, entry->code
		);

#ifndef NDEBUG
		fprintf(out, "  at %s:%u in %s()\n", entry->file, entry->line, entry->func);
#endif
		fprintf(out, "  %s\n", entry->msg);
	}
	fprintf(out, "  ---\n");

	fflush(out);
	_ctx.stack_top = 0;
}

void _err_push(
	ErrorSeverity severity,
	ErrorCode code,
	const char *func,
	const char *file,
	u32 line,
	const char *fmt,
	...
) {
	assert(func);
	assert(file);
	assert(fmt);

	if (severity < _min_severity)
		return; // Skip storing errors below current severity

	if (_ctx.stack_top >= ERR_MAX_STACK_DEPTH)
		err_flush();

	ErrorEntry *entry = &_ctx.stack[_ctx.stack_top];
	_ctx.stack_top += 1;

	entry->severity = severity;
	entry->code = code;
	entry->func = func;
	entry->file = file;
	entry->line = line;
	entry->timestamp = time(nullptr);

	va_list args;
	va_start(args, fmt);
	vsnprintf(entry->msg, ERR_MAX_MESSAGE_LENGTH, fmt, args);
	va_end(args);
}
