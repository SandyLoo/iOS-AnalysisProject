//
//  UITableView+Analysis.m
//  OneKeyAnalysis
//
//  Created by sandy on 2018/7/11.
//  Copyright © 2018年 sandy. All rights reserved.
//

#import "UITableView+Analysis.h"
#import "MethodSwizzingTool.h"
#import <objc/runtime.h>
#import "CaptureTool.h"

@implementation UITableView (Analysis)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        SEL originalAppearSelector = @selector(setDelegate:);
        SEL swizzingAppearSelector = @selector(user_setDelegate:);
        [MethodSwizzingTool swizzingForClass:[self class] originalSel:originalAppearSelector swizzingSel:swizzingAppearSelector];
    });
}



-(void)user_setDelegate:(id<UITableViewDelegate>)delegate
{
    [self user_setDelegate:delegate];
    
    SEL sel = @selector(tableView:didSelectRowAtIndexPath:);
    
    SEL sel_ =  NSSelectorFromString([NSString stringWithFormat:@"%@/%@/%ld", NSStringFromClass([delegate class]), NSStringFromClass([self class]),self.tag]);
    
    
    //因为 tableView:didSelectRowAtIndexPath:方法是optional的，所以没有实现的时候直接return
    if (![self isContainSel:sel inClass:[delegate class]]) {
        
        return;
    }
    
    
    BOOL addsuccess = class_addMethod([delegate class],
                                      sel_,
                                      method_getImplementation(class_getInstanceMethod([self class], @selector(user_tableView:didSelectRowAtIndexPath:))),
                                      nil);
    
    //如果添加成功了就直接交换实现， 如果没有添加成功，说明之前已经添加过并交换过实现了
    if (addsuccess) {
        Method selMethod = class_getInstanceMethod([delegate class], sel);
        Method sel_Method = class_getInstanceMethod([delegate class], sel_);
        method_exchangeImplementations(selMethod, sel_Method);
    }
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


// 由于我们交换了方法， 所以在tableview的 didselected 被调用的时候， 实质调用的是以下方法：
-(void)user_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@/%@/%ld", NSStringFromClass([self class]),  NSStringFromClass([tableView class]), tableView.tag]);
    if ([self respondsToSelector:sel]) {
        IMP imp = [self methodForSelector:sel];
        void (*func)(id, SEL,id,id) = (void *)imp;
        func(self, sel,tableView,indexPath);
    }
    
    
    NSString * identifier = [NSString stringWithFormat:@"%@/%@/%ld", [self class],[tableView class], tableView.tag];
    NSDictionary * dic = [[[DataContainer dataInstance].data objectForKey:@"TABLEVIEW"] objectForKey:identifier];
    if (dic) {
        
        NSString * eventid = dic[@"userDefined"][@"eventid"];
        NSString * targetname = dic[@"userDefined"][@"target"];
        NSString * pageid = dic[@"userDefined"][@"pageid"];
        NSString * pagename = dic[@"userDefined"][@"pagename"];
        NSDictionary * pagePara = dic[@"pagePara"];
        
        
        
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        __block NSMutableDictionary * uploadDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [pagePara enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSInteger containIn = [obj[@"containIn"] integerValue];
            id instance = containIn == 0 ? self : cell;
            id value = [CaptureTool captureVarforInstance:instance withPara:obj];
            if (value && key) {
                [uploadDic setObject:value forKey:key];
            }
        }];
        
        NSLog(@"\n event id === %@,\n  target === %@, \n  pageid === %@,\n  pagename === %@,\n pagepara === %@ \n", eventid, targetname, pageid, pagename, uploadDic);
    }
    
}

@end
