#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdarg.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>
#include <assert.h>
#include "alog.h"

//typedef unsigned char uint8_t;
//typedef char int8_t;

//typedef unsigned short uint16_t;
//typedef short int16_t;

//typedef unsigned int uint32_t;
//typedef int int32_t;

//typedef unsigned long uint64_t;
//typedef long int64_t;

typedef struct TEEC_UUID {
    uint32_t timeLow;
    uint16_t timeMid;
    uint16_t timeHiAndVersion;
    uint8_t clockSeqAndNode[8];
} TEEC_UUID;

static inline unsigned char hexchartovalue(char a)
{
	unsigned char b;
	if(a >= '0' && a <= '9')
	{
		b = a - '0';
	}
	else if(a >= 'a' && a <= 'f')
	{
		b = a - 'a' + 10;
	}
	else if(a >= 'A' && a <= 'F')
	{
		b = a - 'A' + 10;
	}
	else
	{
		SL_LOGE("error a = %c \n",a);
		return -1;
	}
	return b;
}

static int ParseArg(char *str, TEEC_UUID *_puuid)
{
	int i,len;
	unsigned char a,b;
	char* strptr = str;
	char* ptr = NULL;
	len = strlen(str);
	unsigned char buff[sizeof(TEEC_UUID)];
	memset(buff,0,sizeof(TEEC_UUID));
	if(len != sizeof(TEEC_UUID) * 2)	
	{
SL_LOGE("invalid UUID please check the init.rc len = %d TEEC_UUID = %lu",len,sizeof(TEEC_UUID));
		return -1;
	}
	else
	{
		for(i = 0; i < sizeof(TEEC_UUID); i++)
		{
			a = hexchartovalue(*strptr++);
			b = hexchartovalue(*strptr++);
			if(a == -1 || b == -1)
			{
				SL_LOGE("invalid UUID please check the init.rc");
				return -1;
			}
			buff[i] = a<<4 | b;
		}
		//parse timeLow
		_puuid->timeLow = buff[3] | buff[2]<<8 | buff[1]<<16 | buff[0]<<24;
		//parse timeMid
		_puuid->timeMid = buff[5] | buff[4]<<8;
		//parse timeHiAndVersion
		_puuid->timeHiAndVersion = buff[7] | buff[6]<<8;
		//parse clockSeqAndNode
		ptr = (char*)&_puuid->clockSeqAndNode;
		for(i = 0; i < sizeof(_puuid->clockSeqAndNode); i++)
		{
			ptr[i] = buff[8 + i];
		}
	}
	SL_LOGD("uuid = %4x%2x%2x",_puuid->timeLow,_puuid->timeMid,_puuid->timeHiAndVersion);
	for(i = 0;i < sizeof(_puuid->clockSeqAndNode); i ++)
		SL_LOGD("%2x",_puuid->clockSeqAndNode[i]);
	SL_LOGD("\n");
	return 0;
}

int GslParseUuid(int argc, char *args[], TEEC_UUID *_puuid)
{
	int i,ret = -1;
	for(i = 1; i < argc; i++)
	{
		if(strcmp(args[i],"-uuid") == 0)
		{
			i++;
			if(i < argc)
			{
				if(ParseArg(args[i],_puuid))
				{
					SL_LOGD("parse uuid fail continue");
					continue;
				}
				else
				{
					SL_LOGD("parse uuid success");
					ret = 0;
					break;
				}
			}
			else
			{
				SL_LOGE("no uuid avalid please check the init.rc");
			}
		}
	}
	
	if(ret)
		SL_LOGE("no uuid avalid please check the init.rc");
	return ret;
}

int main(int argc, char* argv[])
{
	int i;
	int usageflag = 0;
	TEEC_UUID uuid;
	GslParseUuid(argc,argv,&uuid);
	SL_LOGD("123123%s%d","asdf",234);
//	void* a = malloc(111);
	SL_LOGD("2222");
	for(i = 0; i < argc; i++)
	{
	SL_LOGD("argv[%d] = %s \n",i,argv[i]);
/*
		if(strcmp(argv[i],"-str") == 0)
		{
			usageflag = 1;
			str_test();
			break;
		}
		else if(strcmp(argv[i],"-thread") == 0)
		{
			usageflag = 1;
			thread_test();
			break;
		}
		else if(strcmp(argv[i],"-file") == 0)
		{
			usageflag = 1;
			file_test();
			break;
		}
		else if(strcmp(argv[i],"-env") == 0)
		{
			usageflag = 1;
			env_test();
			break;
		}
		else if(strcmp(argv[i],"-proc") == 0)
		{
			usageflag = 1;
			proc_test();
			break;
		}
		else if(strcmp(argv[i],"-notify") == 0)
		{
			usageflag = 1;
			notify_test();
			break;
		}
		else if(strcmp(argv[i],"-ipc") == 0)
		{
			usageflag = 1;
			ipc_test();
			break;
		}
		else if(strcmp(argv[i],"-ioctl") == 0)
		{
			usageflag = 1;
			ioctl_test();
			break;
		}
*/
	}	
	if(!usageflag)
	{
//		usage();
	}
	return 22;
}


