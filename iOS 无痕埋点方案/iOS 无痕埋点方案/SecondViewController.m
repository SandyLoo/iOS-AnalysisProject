//
//  SecondViewController.m
//  OneKeyAnalysis
//
//  Created by sandy on 2018/7/12.
//  Copyright © 2018年 sandy. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()


@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView * myview = [UIView new];
    myview.backgroundColor = [UIColor yellowColor];
    myview.frame = CGRectMake(0, 0, 200, 50);
    myview.center = self.view.center;
    [self.view addSubview:myview];
    
    UILabel * label = [UILabel new];
    label.text = @"点击触发手势埋点";
    label.frame = CGRectMake(0, 0, 200, 50);
    label.textAlignment = NSTextAlignmentCenter;
    [myview addSubview:label];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clicked:)];
    [myview addGestureRecognizer:tap];
    
    
    UIButton * jumpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    jumpButton.frame = CGRectMake(100, 100, 100, 50);
    jumpButton.backgroundColor = [UIColor grayColor];
    [jumpButton setTitle:@"返回" forState:UIControlStateNormal];
    [jumpButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:jumpButton];
}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)clicked:(UIGestureRecognizer *)ges
{
    
    
}





@end
