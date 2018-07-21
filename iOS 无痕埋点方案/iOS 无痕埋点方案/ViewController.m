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

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic,strong)UITableView * tableView;

@property(nonatomic,strong)NSMutableArray * dataArray;

@property(nonatomic,strong)NSString * testSTR;

@property(nonatomic,strong)NSString * testPara;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.testPara = @"para in page";
   
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.frame = CGRectMake(0, 0, 375, 667);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[MyCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    

    UIView * myview = [UIView new];
    myview.backgroundColor = [UIColor yellowColor];
    myview.frame = CGRectMake(30, 300, 200, 50);
    [self.view addSubview:myview];
    
    UILabel * label = [UILabel new];
    label.text = @"点击触发手势埋点 -1";
    label.frame = CGRectMake(0, 0, 200, 50);
    label.textAlignment = NSTextAlignmentCenter;
    [myview addSubview:label];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controllerclicked:)];
    [myview addGestureRecognizer:tap];
    
    
    UIView * myview1 = [UIView new];
    myview1.backgroundColor = [UIColor yellowColor];
    myview1.frame = CGRectMake(30, 400, 200, 50);
    [self.view addSubview:myview1];
    
    UILabel * label1 = [UILabel new];
    label1.text = @"点击触发手势埋点 -2";
    label1.frame = CGRectMake(0, 0, 200, 50);
    label1.textAlignment = NSTextAlignmentCenter;
    [myview1 addSubview:label1];
    
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controllerclicked123:)];
    [myview1 addGestureRecognizer:tap1];
    
    
    
    
    UIButton * jumpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    jumpButton.frame = CGRectMake(30, 130, 200, 50);
    [jumpButton setTitle:@"点击跳转，已做埋点" forState:UIControlStateNormal];
    jumpButton.backgroundColor = [UIColor grayColor];
    [jumpButton addTarget:self action:@selector(jumpSecond) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:jumpButton];
    
    
}

-(void)controllerclicked:(UIGestureRecognizer *)ges
{
    NSLog(@"手势被点击了 vc");
}

-(void)controllerclicked123:(UIGestureRecognizer *)ges
{
    NSLog(@"手势被点击了 vc");
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
