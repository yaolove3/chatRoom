//
//  ViewController.m
//  chatting
//
//  Created by 林love耀 on 16/4/11.
//  Copyright © 2016年 林love耀. All rights reserved.
//

#import "ViewController.h"
#import "ChattingRoomViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *enter = [UIButton buttonWithType:UIButtonTypeCustom];
    enter.frame=CGRectMake(0, 0, 200, 100);
    enter.center=self.view.center;
    [enter addTarget:self action:@selector(enterClicked) forControlEvents:UIControlEventTouchUpInside];
    [enter setTitle:@"进入聊天室" forState:UIControlStateNormal];
    [enter setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    enter.backgroundColor=[UIColor greenColor];
    [self.view addSubview:enter];
}
-(void)enterClicked
{
    ChattingRoomViewController *chat=[[ChattingRoomViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:chat];
    [self.navigationController pushViewController:nav animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
