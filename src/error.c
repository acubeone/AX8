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

#include "utils.h"

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
