//
//  RootViewController.m
//  OneKeyAnalysis
//
//  Created by lushuangqiang on 2018/12/8.
//  Copyright © 2018 lushuangqiang. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    ViewController * vc = [[ViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
