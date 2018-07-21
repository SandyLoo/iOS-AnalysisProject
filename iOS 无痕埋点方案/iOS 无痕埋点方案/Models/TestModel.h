//
//  TestModel.h
//  OneKeyAnalysis
//
//  Created by sandy on 2018/7/11.
//  Copyright © 2018年 sandy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LikeModel.h"
@interface TestModel : NSObject

@property(nonatomic,assign)NSInteger age;


@property(nonatomic,strong)NSString * name;


@property(nonatomic,strong)NSString * sex;


@property(nonatomic,strong)NSString * genDer;


@property(nonatomic,strong)LikeModel * secondModel;


@end
