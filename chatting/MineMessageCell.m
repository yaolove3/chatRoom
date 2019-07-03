//
//  MineMessageCell.m
//  chatting
//
//  Created by 林love耀 on 16/4/11.
//  Copyright © 2016年 林love耀. All rights reserved.
//

#import "MineMessageCell.h"
#import "MessageModel.h"
#import <Masonry.h>
@implementation MineMessageCell
-(void)setModel:(MessageModel *)model
{
    _model=model;
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"M-d H:m:s"];
    //将时间格式转化为字符串
    NSString *dateStr=[formatter stringFromDate:model.time];
    self.timeLabel.text=dateStr;
    
    [self.contentBtu setTitle:model.text forState:UIControlStateNormal];
    //强制更新
    [self layoutIfNeeded];
    //设置按钮的高度就是titlelabel的高度
    [self.contentBtu mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat buttonH=self.contentBtu.titleLabel.frame.size.height;
        make.height.mas_equalTo(buttonH+30);
    }];
    //强制更新
    [self layoutIfNeeded];
    //计算当前cell的高度
    CGFloat buttonMaxY=CGRectGetMaxY(self.contentBtu.frame);
    CGFloat iconMaxY=CGRectGetMaxY(self.iconView.frame);
    model.cellHeight=MAX(buttonMaxY, iconMaxY)+10;
}

- (void)awakeFromNib {
    self.contentBtu.titleLabel.numberOfLines=0;
    self.contentBtu.contentEdgeInsets=UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
