//
//  MessageModel.h
//  chatting
//
//  Created by 林love耀 on 16/4/11.
//  Copyright © 2016年 林love耀. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageModel : NSObject
/* 注释:时间 */
@property (nonatomic,strong) NSDate *time;
/* 注释:消息 */
@property (nonatomic,strong) NSString *text;
/* 注释:类型 */
@property (nonatomic,copy) NSString *type;
/* 行高 */
@property (nonatomic,assign) CGFloat cellHeight;
@end
