//
//  CrashAvoidConst.h
//  Test
//
//  Created by sandy on 2018/7/9.
//  Copyright © 2018年 sandy. All rights reserved.
//


#ifndef CrashAvoidConst_h
#define CrashAvoidConst_h

#import "CrashAvoidManager.h"
#import <objc/runtime.h>


static NSString * const AvoidCrashDefaultReturnNil     = @"AvoidCrash default is to return nil to avoid crash.";
static NSString * const AvoidCrashDefaultIgnore        = @"AvoidCrash default is to ignore this operation to avoid crash.";
static NSString * const AvoidCrashSeparator            = @"================================================================";
static NSString * const AvoidCrashSeparatorWithFlag    = @"========================CrashAvoid Log==========================";

static NSString * const key_errorName        = @"errorName";
static NSString * const key_errorReason      = @"errorReason";
static NSString * const key_errorPlace       = @"errorPlace";
static NSString * const key_defaultToDo      = @"defaultToDo";
static NSString * const key_callStackSymbols = @"callStackSymbols";
static NSString * const key_exception        = @"exception";

#endif /* CrashAvoidConst_h */
