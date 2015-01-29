//
//  INVLog.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/28/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, INVLogLevel) {
    INVLogLevelDebug,
    INVLogLevelInfo,
    INVLogLevelWarning,
    INVLogLevelError,
    INVLogLevelCritical,
    INVLogLevelCrash,
};

#define INVLogDebug(format...) INVLog(INVLogLevelDebug, format)
#define INVLogInfo(format...) INVLog(INVLogLevelInfo, format)
#define INVLogWarning(format...) INVLog(INVLogLevelWarning, format)
#define INVLogError(format...) INVLog(INVLogLevelError, format)
#define INVLogCritical(format...) INVLog(INVLogLevelCritical, format)
#define INVLogCrash(format...) INVLog(INVLogLevelCrash, format)

#define INVLog(level, format, args...) _INVLog(level, __func__, __FILE__, __LINE__, @"" format, ##args)

extern void _INVLog(INVLogLevel level, const char *func, const char *file, int line, NSString *format, ...)
    NS_FORMAT_FUNCTION(5, 6);
extern void _INVSetLogLevel(INVLogLevel minLevel);