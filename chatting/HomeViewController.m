//
//  HomeViewController.m
//  chatting
//
//  Created by peter on 2019/7/2.
//  Copyright © 2019 林love耀. All rights reserved.
//

#import "HomeViewController.h"
#import "ChattingRoomViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)enterBtnClick:(id)sender {
    ChattingRoomViewController *chat=[[ChattingRoomViewController alloc]init];
    [self.navigationController pushViewController:chat animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
