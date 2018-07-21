//
//  UIViewController+Analysis.m
//  OneKeyAnalysis
//
//  Created by sandy on 2018/7/4.
//  Copyright © 2018年 sandy. All rights reserved.
//

#import "UIViewController+Analysis.h"
#import "MethodSwizzingTool.h"


@implementation UIViewController (Analysis)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalAppearSelector = @selector(viewWillAppear:);
        SEL swizzingAppearSelector = @selector(user_viewWillAppear:);
        [MethodSwizzingTool swizzingForClass:[self class] originalSel:originalAppearSelector swizzingSel:swizzingAppearSelector];
        
        SEL originalDisappearSelector = @selector(viewWillDisappear:);
        SEL swizzingDisappearSelector = @selector(user_viewWillDisappear:);
        [MethodSwizzingTool swizzingForClass:[self class] originalSel:originalDisappearSelector swizzingSel:swizzingDisappearSelector];
        
        SEL originalDidLoadSelector = @selector(viewDidLoad);
        SEL swizzingDidLoadSelector = @selector(user_viewDidLoad);
        [MethodSwizzingTool swizzingForClass:[self class] originalSel:originalDidLoadSelector swizzingSel:swizzingDidLoadSelector];
        
    });
}


-(void)user_viewWillAppear:(BOOL)animated
{
    [self user_viewWillAppear:animated];
}


-(void)user_viewWillDisappear:(BOOL)animated
{
    [self user_viewWillDisappear:animated];
    
}

-(void)user_viewDidLoad
{
    
    [self user_viewDidLoad];
    
    
    NSString * identifier = [NSString stringWithFormat:@"%@", [self class]];
    NSDictionary * dic = [[[DataContainer dataInstance].data objectForKey:@"PAGEPV"] objectForKey:identifier];
    if (dic) {
        NSString * pageid = dic[@"userDefined"][@"pageid"];
        NSString * pagename = dic[@"userDefined"][@"pagename"];
        NSDictionary * pagePara = dic[@"pagePara"];
        
        __block NSMutableDictionary * uploadDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [pagePara enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            id value = [CaptureTool captureVarforInstance:self withPara:obj];
            if (value && key) {
                [uploadDic setObject:value forKey:key];
            }
        }];
        
        
        NSLog(@"\n  pageid === %@,\n  pagename === %@,\n pagepara === %@ \n", pageid, pagename, uploadDic);
    }
}


@end
