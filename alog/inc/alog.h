/*
 * =====================================================================================
 *
 *       Filename:  sl_log.h
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  
 *        Revision:  none
 *
 *         Author:  WY, 
 *        Company:  
 *
 * =====================================================================================
 */
#ifndef __SL_LOG_H__
#define __SL_LOG_H__



#ifdef __cplusplus
extern "C"
{
#endif

//TODO xml control log priority
typedef enum sl_LogPriority {
    SL_LOG_SILENT = 0,     /* only for SetMinPriority(); must be last */
    SL_LOG_UNKNOWN,
    SL_LOG_DEFAULT,    /* only for SetMinPriority() */
    SL_LOG_VERBOSE,
    SL_LOG_DEBUG,
    SL_LOG_INFO,
    SL_LOG_WARN,
    SL_LOG_ERROR,
    SL_LOG_FATAL,
	SL_LOG_MAX
} sl_LogPriority;



#define SLLOGTAGD "SLCODE D "
#define SLLOGTAGE "SLCODE E "
int sl_log_printf(int prio,const char *fmt, ...);

#ifndef SL_LOGD
#define SL_LOGD(f,...)	\
	do {	\
	sl_log_printf(SL_LOG_VERBOSE,"SLCODE D %-15s:%04d => "f, __FUNCTION__, __LINE__,##__VA_ARGS__);	\
	} while(0)
#endif

#ifndef SL_LOGE
#define SL_LOGE(f,...)	\
	do {	\
	sl_log_printf(SL_LOG_ERROR,"SLCODE E %-15s:%04d => "f, __FUNCTION__, __LINE__,##__VA_ARGS__);	\
	} while(0)
#endif

#define SL_LOGU		SL_LOGD
#define SL_LOGV		SL_LOGD
#define SL_LOGI		SL_LOGD
#define SL_LOGW		SL_LOGD
#define SL_LOGF		SL_LOGE


#ifdef __cplusplus
}
#endif

#endif
