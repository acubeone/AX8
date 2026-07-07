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

#pragma once

#include "basic_types.h"

#include <stdio.h>
#include <time.h>

#ifndef __FILE_NAME__
#	define __FILE_NAME__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)
#endif

#define _push_info(...) \
	_err_push(SEVERITY_INFO, ERR_SUCCESS, __func__, __FILE_NAME__, __LINE__, __VA_ARGS__)
#define _push_warn(...) \
	_err_push(SEVERITY_WARN, ERR_SUCCESS, __func__, __FILE_NAME__, __LINE__, __VA_ARGS__)
#define _push_error(code, ...)                                                      \
	_err_push(SEVERITY_ERROR, code, __func__, __FILE_NAME__, __LINE__, __VA_ARGS__)
#define _push_fatal(code, ...)                                                      \
	_err_push(SEVERITY_FATAL, code, __func__, __FILE_NAME__, __LINE__, __VA_ARGS__)

enum {
	ERR_MAX_STACK_DEPTH = 64,
	ERR_MAX_MESSAGE_LENGTH = 256,
};

typedef enum ErrorCode {
	ERR_SUCCESS = 0,
	ERR_GENERIC,
	ERR_INVALID_ARGS,
	ERR_OUT_OF_MEMORY,
	ERR_IO,
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
