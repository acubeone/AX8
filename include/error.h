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

#include "utils.h"

#include <stdio.h>
#include <time.h>

#ifndef __FILE_NAME__
#	define __FILE_NAME__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)
#endif

#define log_info(...) \
	_err_push(SEVERITY_INFO, ERR_SUCCESS, __func__, __FILE_NAME__, __LINE__, __VA_ARGS__)
#define log_warn(...) \
	_err_push(SEVERITY_WARN, ERR_SUCCESS, __func__, __FILE_NAME__, __LINE__, __VA_ARGS__)
#define log_error(code, ...)                                                        \
	_err_push(SEVERITY_ERROR, code, __func__, __FILE_NAME__, __LINE__, __VA_ARGS__)
#define log_fatal(code, ...)                                                        \
	_err_push(SEVERITY_FATAL, code, __func__, __FILE_NAME__, __LINE__, __VA_ARGS__)

#define _PUSH_ERROR(pos, code, msg, ...)                                                \
	{                                                                                   \
		log_error(                                                                      \
			code, "At %zu:%zu - " msg, pos.lineno, pos.colno __VA_OPT__(, ) __VA_ARGS__ \
		);                                                                              \
		return code;                                                                    \
	}

enum {
	ERR_MAX_STACK_DEPTH = 64,
	ERR_MAX_MESSAGE_LENGTH = 256,
};

typedef enum ErrorCode {
	// Generic (0x00 - 0x0f)
	ERR_SUCCESS = 0x00,
	ERR_GENERIC = 0x01,
	ERR_INVALID_ARGS = 0x02,
	ERR_OUT_OF_MEMORY = 0x03,
	ERR_IO = 0x04,

	// Lexer (0x10 - 0x1f)
	ERR_LEX_EOF = 0x10,
	ERR_LEX_INVALID = 0x11,
	ERR_LEX_EXPECTED_DIGIT = 0x12,
} ErrorCode;

typedef enum ErrorSeverity {
	SEVERITY_INFO,
	SEVERITY_WARN,
	SEVERITY_ERROR,
	SEVERITY_FATAL,
} ErrorSeverity;

typedef struct ErrorEntry {
	ErrorSeverity severity;
	ErrorCode code;
	const char *func;
	const char *file;
	u32 line;
	time_t timestamp;
	char msg[ERR_MAX_MESSAGE_LENGTH];
} ErrorEntry;

void err_flush(void);

const ErrorEntry *query_last_error(void);

void set_err_min_severity(ErrorSeverity min_level);
void set_err_stream(FILE *stream);

void _err_push(
	ErrorSeverity severity,
	ErrorCode code,
	const char *func,
	const char *file,
	u32 line,
	const char *fmt,
	...
);
