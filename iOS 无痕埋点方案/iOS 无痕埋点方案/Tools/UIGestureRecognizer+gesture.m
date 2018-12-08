//
//  UIGestureRecognizer+gesture.m
//  OneKeyAnalysis
//
//  Created by sandy on 2018/12/8.
//  Copyright © 2018 sandy. All rights reserved.
//

#import "UIGestureRecognizer+gesture.h"
#import <objc/runtime.h>


@implementation UIGestureRecognizer (gesture)


-(void)setMethodName:(NSString *)methodName
{
    objc_setAssociatedObject(self, @"methodName", methodName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


-(NSString *)methodName
{
    return objc_getAssociatedObject(self, @"methodName");
}
@end
