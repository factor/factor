/*
 *  pms.m
 *
 *  Created by Dave Carlton on 10/12/09.
 *  Copyright 2009 PolyMicro Systems. All rights reserved.
 *
 */

#include <stdio.h>
#include <stdarg.h>
#include <sys/time.h>
#include "pms.h"

int				gDebugLevel = 1;
int				gVerboseIndex = 0;
Boolean			gVerboseStack[256];
UInt64			startTime = 0;

// PMLOGSetVerbose sets a new debug level
void PMLOGSetVerbose(Boolean value) 
    { gDebugLevel = value; }

// PMLOGPushVerbose sets a new debug setting and saves the previous one
// Use this to reduce debug output inside loops etc.
void PMLOGPushVerbose(Boolean value) {
	gVerboseStack[gVerboseIndex] = gDebugLevel;
	gVerboseIndex++;
	if (gVerboseIndex > 256)
		gVerboseIndex = 256;
	gDebugLevel = value;
}

// PMLOGPopVerbose restores the previous debug setting
void PMLOGPopVerbose(void) {
	gVerboseIndex--;
	if (gVerboseIndex < 0)
		gVerboseIndex = 0;
	gDebugLevel = gVerboseStack[gVerboseIndex];
}

static NSString* 
_PMLOGFormat(id self, NSString * prefix, NSString * format) {
	if(self != nil)
	{
		return [NSString stringWithFormat:@"%@ self(%@) %@", prefix, self, format];
	}
	else
	{
		return [NSString stringWithFormat:@"%@ %@", prefix, format];
	}
}

void _PMLOGSELF(id self, NSString * format, ...)
{
	NSString * finalFormat = _PMLOGFormat(self, @"PMLOG", format);
	va_list ap;
	va_start(ap, format);
	NSLogv(finalFormat, ap);
	va_end(ap);
}

void _PMMSG(const char *function,  int inLevel, NSString * format, ...)
{
    if( inLevel > gDebugLevel || inLevel == 0 )
    {
		// The level is not high enough to be displayed, we're skipping this item.
		// inLevel = 0 = disabled          PMLOG(0, @"log, but disabled");
		// gDebugLevel = 1 = least verbose PMLOG(1, @"Routine log");
		// gDebugLevel = 7 = most verbose  PMLOG(5, @"Really detailed debug level");
        return;
    }
    else
    {
        NSString *		finalFormat =  [NSString stringWithFormat:@"PMLOG: %s: %@", function, format];
        
        va_list ap;
        va_start(ap, format);
        NSLogv(finalFormat, ap);
        va_end(ap);
    }
}

void _PMLOG(const char *file, const char *function,  int inLevel, NSString * format, ...)
{
    if( inLevel > gDebugLevel || inLevel == 0 )
    {
		// The level is not high enough to be displayed, we're skipping this item.
		// inLevel = 0 = disabled          PMLOG(0, @"log, but disabled");
		// gDebugLevel = 1 = least verbose PMLOG(1, @"Routine log");
		// gDebugLevel = 7 = most verbose  PMLOG(7, @"Really detailed debug level");
        return;
    }
    else
    {
		NSString *		pathString = [NSString stringWithCString:file encoding:NSUTF8StringEncoding];
        const char *	fileString = [[pathString lastPathComponent] cStringUsingEncoding: NSUTF8StringEncoding];
        NSString *		finalFormat =  [NSString stringWithFormat:@"PMLOG %s: %s: %@", fileString, function, format];
        
        va_list ap;
        va_start(ap, format);
        NSLogv(finalFormat, ap);
        va_end(ap);
    }
}

void _PMERR(const char *file, const char *function, int err, NSString * format, ...) {
	NSString *		pathString = [NSString stringWithCString:file encoding:NSUTF8StringEncoding];
	const char *	fileString = [[pathString lastPathComponent] cStringUsingEncoding: NSUTF8StringEncoding];
	NSString *		finalFormat =  [NSString stringWithFormat:@"PMLOG %s: %s: %@ - err: %x", fileString, function, format, err];
	
	va_list ap;
	va_start(ap, format);
	NSLogv(finalFormat, ap);
	va_end(ap);
	
}
