//
//  NSObject+avoid.m
//  OneKeyAnalysis
//
//  Created by sandy on 2018/7/12.
//  Copyright © 2018年 sandy. All rights reserved.
//

#import "NSObject+avoid.h"
#import "CrashAvoidConst.h"

@implementation NSObject (avoid)
+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        //valueForKey:
        Class anClass = [self class];
        SEL method1Sel = @selector(valueForKey:);
        SEL method2Sel = @selector(safe_valueForKey:);

        [CrashAvoidManager exchangeInstanceMethod:anClass method1Sel:method1Sel method2Sel:method2Sel];
    });
}


-(id)safe_valueForKey:(NSString *)key
{
    id object = nil;
    
    @try {
        object = [self safe_valueForKey:key];
    }
    @catch (NSException *exception) {
  
    }
    @finally {
        return object;
    }
}
@end
