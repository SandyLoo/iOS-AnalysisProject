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
    

    //手势3
    UILabel * tapLabel3 = [[UILabel alloc]init];
    tapLabel3.frame = CGRectMake(0,0, 200, 50);
    tapLabel3.text = @"点击触发手势埋点";
    tapLabel3.textAlignment = NSTextAlignmentCenter;
    tapLabel3.textColor = [UIColor whiteColor];
    tapLabel3.backgroundColor = [UIColor grayColor];
    tapLabel3.userInteractionEnabled = YES;
    tapLabel3.center = self.view.center;
    [self.view addSubview:tapLabel3];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gesture3clicked:)];
    [tapLabel3 addGestureRecognizer:tap1];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gesture3clicked:)];
    [tapLabel3 addGestureRecognizer:tap];
    
    
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

-(void)gesture3clicked:(UIGestureRecognizer *)ges
{
    
    
}





@end
