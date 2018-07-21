//
//  MethodSwizzingTool.h
//  OneKeyAnalysis
//
//  Created by sandy on 2018/7/4.
//  Copyright © 2018年 sandy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MethodSwizzingTool : NSObject


+(void)swizzingForClass:(Class)cls originalSel:(SEL)originalSelector swizzingSel:(SEL)swizzingSelector;


+(NSDictionary *)getConfig;

@end
