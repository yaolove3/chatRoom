//
//  MineMessageCell.h
//  chatting
//
//  Created by 林love耀 on 16/4/11.
//  Copyright © 2016年 林love耀. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MessageModel;
@interface MineMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *contentBtu;
/* 注释:模型 */
@property (nonatomic,strong) MessageModel *model;
@end
