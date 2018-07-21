//
//  CrashAvoidManager.h
//  Test
//
//  Created by sandy on 2018/7/9.
//  Copyright © 2018年 sandy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashAvoidManager : NSObject

/**
 交换类方法

 @param anClass 类
 @param method1Sel 原方法
 @param method2Sel 交换后的方法
 */
+ (void)exchangeClassMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel;

/**
 交换对象方法
 
 @param anClass 类
 @param method1Sel 原方法
 @param method2Sel 交换后的方法
 */
+ (void)exchangeInstanceMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel;



/**
 当检测到error时会调用此方法， 方法内对exception进行解析，并获取堆栈信息上传到bugly

 @param exception 异常信息
 @param defaultToDo 默认的异常处理做法
 */
+ (void)noteErrorWithException:(NSException *)exception defaultToDo:(NSString *)defaultToDo;


@end
