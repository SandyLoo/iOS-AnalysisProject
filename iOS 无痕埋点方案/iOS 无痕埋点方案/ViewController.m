//
//  ViewController.m
//  OneKeyAnalysis
//
//  Created by sandy on 2018/7/4.
//  Copyright © 2018年 sandy. All rights reserved.
//

#import "ViewController.h"
#import "TestModel.h"
#import "MyCell.h"
#import <objc/runtime.h>
#import "CaptureTool.h"
#import "LikeModel.h"
#import "ThirdModel.h"
#import "SecondViewController.h"
#import "DataContainer.h"
#import "TestTableview.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic,strong)TestTableview * tableView;

@property(nonatomic,strong)NSMutableArray * dataArray;

@property(nonatomic,strong)NSString * testSTR;

@property(nonatomic,strong)NSString * testPara;


@end

@implementation ViewController

-(void)dealloc
{
    NSLog(@"ViewController 释放");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.testPara = @"para in page";
    
    
    self.tableView = [[TestTableview alloc]init];
    self.tableView.frame = CGRectMake(0, 250, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[MyCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    
    
    //点击
    UIButton * jumpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    jumpButton.frame = CGRectMake(30, 80, 200, 50);
    [jumpButton setTitle:@"点击跳转，已做埋点" forState:UIControlStateNormal];
    jumpButton.backgroundColor = [UIColor grayColor];
    [jumpButton addTarget:self action:@selector(jumpSecond) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:jumpButton];
    
    
    //手势1
    UILabel * tapLabel1 = [[UILabel alloc]init];
    tapLabel1.frame = CGRectMake(30,140, 200, 50);
    tapLabel1.text = @"点击触发手势埋点 -1";
    tapLabel1.textAlignment = NSTextAlignmentCenter;
    tapLabel1.textColor = [UIColor whiteColor];
    tapLabel1.backgroundColor = [UIColor grayColor];
    tapLabel1.userInteractionEnabled = YES;
    [self.view addSubview:tapLabel1];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gesture1clicked:)];
    [tapLabel1 addGestureRecognizer:tap1];
    
    
    //手势2
    UILabel * tapLabel2 = [[UILabel alloc]init];
    tapLabel2.frame = CGRectMake(30,200, 200, 50);
    tapLabel2.text = @"点击触发手势埋点 2";
    tapLabel2.textAlignment = NSTextAlignmentCenter;
    tapLabel2.textColor = [UIColor whiteColor];
    tapLabel2.backgroundColor = [UIColor grayColor];
    tapLabel2.userInteractionEnabled = YES;
    [self.view addSubview:tapLabel2];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gesture2clicked:)];
    [tapLabel2 addGestureRecognizer:tap2];
    
}

-(void)gesture1clicked:(UIGestureRecognizer *)ges
{
    NSLog(@"手势1触发");
}

-(void)gesture2clicked:(UIGestureRecognizer *)ges
{
    NSLog(@"手势2触发");
}


-(void)jumpSecond
{
    SecondViewController * second = [[SecondViewController alloc]init];
    second.age = 118;
    [self presentViewController:second animated:YES completion:nil];
}




-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    TestModel * model = self.dataArray[indexPath.row];
    
    cell.model = model;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TestModel * model = self.dataArray[indexPath.row];
    NSLog(@"name ==  %@", model.name);
}



-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
        
        for (int i = 0 ; i < 30; i++) {
            TestModel * model = [[TestModel alloc]init];
            model.age = i;
            model.name = [NSString stringWithFormat:@"zhangsan - %d", i];
            model.sex = @"male";
            
            LikeModel * model2 = [LikeModel new];
            model2.goods = @"abcd";
            
            ThirdModel * model3 = [[ThirdModel alloc]init];
            model3.grade = [[NSString stringWithFormat:@"%d", 100 + i] integerValue];
            model3.sex1 = @"male";
            
            model.secondModel = model2;
            model.secondModel.model3 = model3;
            
            
            [_dataArray addObject:model];
        }
    }
    return _dataArray;
}


@end

