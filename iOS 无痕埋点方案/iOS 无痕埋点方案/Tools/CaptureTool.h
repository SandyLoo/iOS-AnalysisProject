//
//  VarCaptureTool.h
//  OneKeyAnalysis
//
//  Created by sandy on 2018/7/12.
//  Copyright © 2018年 sandy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CaptureTool : NSObject

/**
 根据属性名获取某个对象的对应属性的值

 @param instance 持有属性的对象
 @param varName 属性的名字
 @return 属性对应的value
 */
+(id)captureVarforInstance:(id)instance varName:(NSString *)varName;



/**
 利用配置表中的para参数，从指定实例取值

 @param instance 参数的持有者
 @param para 配置表中的pagePara值
 @return 取到的值
 */
+(id)captureVarforInstance:(id)instance withPara:(NSDictionary *)para;


@end
