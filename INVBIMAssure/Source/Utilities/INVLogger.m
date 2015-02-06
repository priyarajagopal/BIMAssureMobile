//
//  INVLog.m
//  INVBIMAssure
//
//  Created by Richard Ross on 1/28/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#import "INVLogger.h"

#if DEBUG

static INVLogLevel _INVMinimumLogLevel = INVLogLevelDebug;
static BOOL _INVFileLoggingEnabled = NO;

#else

static INVLogLevel _INVMinimumLogLevel = INVLogLevelError;
static BOOL _INVFileLoggingEnabled = NO;

#endif

void _INVSetLogLevel(INVLogLevel minLevel)
{
    _INVMinimumLogLevel = minLevel;
}

static inline NSString *invLogLevelToString(INVLogLevel level)
{
    static NSString *levels[] = {
        @"DEBUG",
        @"INFO",
        @"WARNING",
        @"ERROR",
        @"CRITICAL",
        @"CRASH",
    };

    return levels[level];
}

static inline BOOL shouldShowCallstackSymbolsForLevel(INVLogLevel level)
{
    static BOOL levels[] = {
        NO,  // Debug
        NO,  // Info
        YES, // Warning
        YES, // Error
        YES, // Critical
        YES, // Crash
    };

    return levels[level];
}

static inline void writeLogfilePreamble(FILE *logFile, NSDateFormatter *dateFormat)
{
    NSString *logFilePreamble =
        [NSString stringWithFormat:@"\n\n---- BEGIN RUN AT %@ ----\n\n", [dateFormat stringFromDate:[NSDate date]]];
    NSData *logFilePreambleData = [logFilePreamble dataUsingEncoding:NSUTF8StringEncoding];

    fwrite([logFilePreambleData bytes], 1, [logFilePreambleData length], logFile);
}

static inline void writeLogfilePostamble(FILE *logFile, NSDateFormatter *dateFormat)
{
    NSString *logFilePreamble =
        [NSString stringWithFormat:@"\n\n---- END RUN AT %@ ----\n\n", [dateFormat stringFromDate:[NSDate date]]];
    NSData *logFilePreambleData = [logFilePreamble dataUsingEncoding:NSUTF8StringEncoding];

    fwrite([logFilePreambleData bytes], 1, [logFilePreambleData length], logFile);
}

void _INVLog(INVLogLevel level, const char *func, const char *file, int line, NSString *format, ...)
{
    if (level < _INVMinimumLogLevel)
        return;

    NSArray *callstackSymbols = nil;

    if (shouldShowCallstackSymbolsForLevel(level)) {
        callstackSymbols = [NSThread callStackSymbols];
        callstackSymbols = [callstackSymbols subarrayWithRange:NSMakeRange(1, callstackSymbols.count - 1)];
    }

    NSDate *logDate = [NSDate date];

    va_list arguments;
    va_start(arguments, format);

    NSString *formatStr = [[NSString alloc] initWithFormat:format arguments:arguments];

    va_end(arguments);

    static dispatch_queue_t logging_queue;
    static NSDateFormatter *dateFormat;
    static FILE *stderrPtr;
    static FILE *logfilePtr;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logging_queue = dispatch_queue_create("INVLogger", NULL);

        stderrPtr = stderr;

        dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyy-MM-dd hh:mm:ss"];

        if (_INVFileLoggingEnabled) {
            NSString *logPath =
                [[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]]
                    stringByAppendingPathExtension:@"log"];
            logfilePtr = fopen([logPath UTF8String], "a");

            writeLogfilePreamble(logfilePtr, dateFormat);

            atexit_b(^{
                writeLogfilePostamble(logfilePtr, dateFormat);
                fclose(logfilePtr);
            });
        }
    });

    dispatch_async(logging_queue, ^{
        NSMutableString *outputString = [NSMutableString new];

        [outputString appendFormat:@"%@\t%@\t", [dateFormat stringFromDate:logDate], invLogLevelToString(level)];
        [outputString appendFormat:@"%@:%d\t", [@(file) lastPathComponent], line];
        [outputString appendFormat:@"%s", func];

        if (callstackSymbols) {
            [outputString appendFormat:@" %@", callstackSymbols];
        }

        if ([formatStr length]) {
            [outputString appendFormat:@": %@", formatStr];
        }

        [outputString appendString:@"\n\n"];

        NSData *data = [outputString dataUsingEncoding:NSUTF8StringEncoding];
        fwrite([data bytes], 1, [data length], stderrPtr);
        fflush(stderrPtr);

        if (logfilePtr) {
            fwrite([data bytes], 1, [data length], logfilePtr);
            fflush(logfilePtr);
        }
    });
}