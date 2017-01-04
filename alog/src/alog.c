#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <fcntl.h>
#include <errno.h>
#include "alog.h"

#define SL_LOG_BUFSIZE 255
static char buf[SL_LOG_BUFSIZE+1];

int sl_log_printf(int prio,const char *fmt, ...)
{
	va_list ap;
	va_start(ap, fmt);
//	vsnprintf(buf, SL_LOG_BUFSIZE, fmt, ap);
	va_end(ap);
//	TEE_LogPrintf("%s",buf);
	return 0;
}

