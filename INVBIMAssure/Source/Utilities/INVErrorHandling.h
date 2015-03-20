//
//  INVErrorHandling.h
//  INVBIMAssure
//
//  Created by Richard Ross on 1/28/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//

#define INV_COMPLETION_HANDLER ^(INVEmpireMobileError * error)

#define INV_ALWAYS                                                                                                             \
    int times = 0;                                                                                                             \
    __handler_start:                                                                                                           \
    if (times == 0) {                                                                                                          \
        times++;                                                                                                               \
        goto __always_handler;                                                                                                 \
    }                                                                                                                          \
    else {                                                                                                                     \
        if (times == 2)                                                                                                        \
            return;                                                                                                            \
        times++;                                                                                                               \
                                                                                                                               \
        if (error) {                                                                                                           \
            goto __error_handler;                                                                                              \
        }                                                                                                                      \
        else {                                                                                                                 \
            goto __success_handler;                                                                                            \
        }                                                                                                                      \
    }                                                                                                                          \
                                                                                                                               \
    __always_handler

#define INV_SUCCESS                                                                                                            \
    goto __handler_start;                                                                                                      \
    __success_handler
#define INV_ERROR                                                                                                              \
    goto __handler_start;                                                                                                      \
    __error_handler

extern NSString *const INVEmpireMobileErrorDomain;