//
//  UICollectionView+Analysis.m
//  OneKeyAnalysis
//
//  Created by sandy on 2018/7/12.
//  Copyright © 2018年 sandy. All rights reserved.
//

#import "UICollectionView+Analysis.h"
#import "MethodSwizzingTool.h"
#import <objc/runtime.h>

@implementation UICollectionView (Analysis)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        SEL originalAppearSelector = @selector(setDelegate:);
        SEL swizzingAppearSelector = @selector(user_setDelegate:);
        [MethodSwizzingTool swizzingForClass:[self class] originalSel:originalAppearSelector swizzingSel:swizzingAppearSelector];
    });
}


-(void)user_setDelegate:(id<UICollectionViewDelegate>)delegate
{
    [self user_setDelegate:delegate];
    
    SEL sel = @selector(collectionView:didSelectItemAtIndexPath:);
    
    SEL sel_ =  NSSelectorFromString(@"userDefined_collectionView_didselected");
    
    class_addMethod([delegate class],
                    sel_,
                    method_getImplementation(class_getInstanceMethod([self class], @selector(user_collectionView:didSelectItemAtIndexPath:))),
                    nil);
    
    
    //判断是否有实现，没有的话添加一个实现
    if (![self isContainSel:sel inClass:[delegate class]]) {
        IMP imp = method_getImplementation(class_getInstanceMethod([delegate class], sel));
        class_addMethod([delegate class], sel, imp, nil);
    }
    
    
    // 将swizzle delegate method 和 origin delegate method 交换
    [MethodSwizzingTool swizzingForClass:[delegate class] originalSel:sel swizzingSel:sel_];
}


//判断页面是否实现了某个sel
- (BOOL)isContainSel:(SEL)sel inClass:(Class)class {
    unsigned int count;
    
    Method *methodList = class_copyMethodList(class,&count);
    for (int i = 0; i < count; i++) {
        Method method = methodList[i];
        NSString *tempMethodString = [NSString stringWithUTF8String:sel_getName(method_getName(method))];
        if ([tempMethodString isEqualToString:NSStringFromSelector(sel)]) {
            return YES;
        }
    }
    return NO;
}



- (void)user_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    SEL sel = NSSelectorFromString(@"userDefined_collectionView_didselected");
    if ([self respondsToSelector:sel]) {
        IMP imp = [self methodForSelector:sel];
        void (*func)(id, SEL,id,id) = (void *)imp;
        func(self, sel,collectionView,indexPath);
    }
}

@end
