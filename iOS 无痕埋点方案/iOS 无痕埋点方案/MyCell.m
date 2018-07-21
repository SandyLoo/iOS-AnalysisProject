//
//  MyCell.m
//  OneKeyAnalysis
//
//  Created by sandy on 2018/7/11.
//  Copyright © 2018年 sandy. All rights reserved.
//

#import "MyCell.h"

@implementation MyCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

-(void)setModel:(TestModel *)model
{
    _model = model;
    
    self.textLabel.text = model.name;
}

@end
