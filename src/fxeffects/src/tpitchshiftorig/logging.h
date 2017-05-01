#ifndef LOGGING_H
#define LOGGING_H

#ifdef _DEBUG
//#ifndef IMPOSSIVEL
#include<stdio.h>

//CONFIGURACOES (devem ser usados nos ficheiros a serem logados)
//#define LOG_LEVEL LOG_INFO

#define LOG_DEBUG	1	//toda a info
#define LOG_INFO	2	//informação
#define LOG_WARN	3	//warning
#define LOG_ERROR	4	//erro
#define LOG_FATAL	5	//fatal error (erro que pode abortar o programa)

#ifndef LOG_LEVEL
#error "LOG_LEVEL not defined" 
#endif

#define LOG(loglevel,...) \
	if(loglevel>=LOG_LEVEL)\
	switch(loglevel){\
		case LOG_DEBUG: printf("DEBUG\t%d:%s\t",__LINE__,__FILE__,__FUNCTION__); printf(__VA_ARGS__); printf("\n");	break; \
		case LOG_INFO:  printf("INFO\t%d:%s\t%s\t",__LINE__,__FILE__,__FUNCTION__);printf(__VA_ARGS__); printf("\n"); break;\
		case LOG_WARN:  printf("WARN\t%d:%s\t%s\t",__LINE__,__FILE__,__FUNCTION__);printf(__VA_ARGS__); printf("\n"); break;\
		case LOG_ERROR: printf("ERROR\t%d:%s\t%s\t",__LINE__,__FILE__,__FUNCTION__);printf(__VA_ARGS__); printf("\n"); break;\
		case LOG_FATAL: printf("FATAL\t%d:%s\t%s\t",__LINE__,__FILE__,__FUNCTION__);printf(__VA_ARGS__); printf("\n"); break;\
	}

#else
#define LOG(x,...) {}
#endif

#endif
