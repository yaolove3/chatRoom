//
//  ChattingRoomViewController.m
//  chatting
//
//  Created by 林love耀 on 16/4/11.
//  Copyright © 2016年 林love耀. All rights reserved.
//

#import "ChattingRoomViewController.h"
#import "GCDAsyncSocket.h"
#import "MessageModel.h"
#import "MineMessageCell.h"
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
@interface ChattingRoomViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic)  UILabel *friendLabel;
@property (strong, nonatomic)  UITableView *tableView;
@property (strong, nonatomic)  UIButton *sendButton;
@property (strong, nonatomic)  UITextField *textField;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic, assign) BOOL isConnectting;//是否正在连接

@property (nonatomic,strong)GCDAsyncSocket *clientScoket;
@property (nonatomic, strong) dispatch_source_t timer;

@end

static NSString* serverIp = @"192.168.3.51";
static NSInteger serverPort = 8888;

@implementation ChattingRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    imageView.image=[UIImage imageNamed:@"backView"];
    [self.view addSubview:imageView];
    [self createTableView];
    [self createUI];
    //注册通知中心
    NSNotificationCenter *not=[NSNotificationCenter defaultCenter];
    [not addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [not addObserver:self selector:@selector(keyBoardWillMiss:) name:UIKeyboardWillHideNotification object:nil];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back_n_gray"] style:0 target:self action:@selector(onNavBackButton:)] ;
    self.navigationItem.leftBarButtonItem = item ;
    
    //及时交互部分
    //实现聊天室
    //创建一个客户端scoket对象
    GCDAsyncSocket *clientScoket=[[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    self.clientScoket=clientScoket;
    //发送连接请求
    NSError *error=nil;
    [clientScoket connectToHost:serverIp onPort:serverPort error:&error];
    if (!error) {
        NSLog(@"error--%@",error);
    }
}
/* 注释:懒加载 */
-(NSMutableArray *)dataArray{
    if (_dataArray==nil) {
        _dataArray=[NSMutableArray array];
    }
    return _dataArray;
}
-(void)createTableView{
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 50 , WIDTH, HEIGHT-100) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.backgroundColor=[UIColor clearColor];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.transform=CGAffineTransformMakeRotation(2*M_PI_2);
    [self.view addSubview:_tableView];
}
-(void)createUI{
    self.title = @"倒斗小分队";
    
    _textField=[[UITextField alloc]initWithFrame:CGRectMake(20, HEIGHT-50, WIDTH-20-100, 40)];
    _textField.backgroundColor=[UIColor whiteColor];
    _textField.keyboardType=UIKeyboardTypeNamePhonePad;
    _textField.layer.cornerRadius=10;
    [self.view addSubview:_textField];
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton.frame=CGRectMake(WIDTH-100 + 10, HEIGHT-50, 80, 40);
    [_sendButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    _sendButton.backgroundColor=[UIColor blueColor];
    _sendButton.layer.cornerRadius=10;
    _sendButton.layer.masksToBounds=YES;
    [self.view addSubview:_sendButton];
}

-(void)buttonClicked{
    //发数据
    NSString *send=self.textField.text;
    if (send.length==0) {
        return;
    }
    NSData *sendData=[send dataUsingEncoding:NSUTF8StringEncoding];
    [self.clientScoket writeData:sendData withTimeout:-1 tag:0];
    MessageModel *model=[[MessageModel alloc]init];
    model.text=send;
    model.type=@"mine";
    model.time=[NSDate date];
    [self.dataArray insertObject:model atIndex:0];
    [self.tableView reloadData];
    self.textField.text=nil;
}

- (void)onNavBackButton:(id)sender {
    //主动退出就不用重新连接了
    self.isConnectting = YES;
    [self.clientScoket disconnect];
    [self.navigationController popViewControllerAnimated:YES] ;
}
#pragma mark---GCDsocket代理方法
#pragma mark ----------------客户端socket成功连接到服务器---------------
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"与服务器连接成功");
    
    //连接成功后开始监听服务端发来的消息
    [sock readDataWithTimeout:-1 tag:0];
}

#pragma mark ----------------客户端socket与服务器断开连接---------------
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"与服务器断开连接");
    
    //如果是由于网络原因非主动断开连接的可以尝试重新连接
    [self reConnect:sock];
}

#pragma mark ----------------客户端接收到服务器发来的消息---------------
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *receive=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //此处进行UI处理，比如将获取到的数据显示到页面上，注意这里是在子线程，进行UI操作需回到主线程刷新
    if (receive) {
        MessageModel *model=[[MessageModel alloc]init];
        model.text=receive;
        model.type=@"other";
        model.time=[NSDate date];
        [self.dataArray insertObject:model atIndex:0];
        //回到主线程刷新表格
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            //发送本地通知，接收到服务端消息
            [self sendNotiWithModel:model];
            [self.tableView reloadData];
        }];
    }
    
    //与服务端代码一样，读完一次数据后需继续调用一次监听方法监听读取数据
    [sock readDataWithTimeout:-1 tag:0];
}

-(void)sendNotiWithModel:(MessageModel *)model{
    //发送通知
    UILocalNotification *localNoti=[[UILocalNotification alloc]init];
    localNoti.alertBody=model.text;
    localNoti.soundName=UILocalNotificationDefaultSoundName;
    localNoti.fireDate=[NSDate dateWithTimeIntervalSinceNow:1.0];
    [[UIApplication sharedApplication]scheduleLocalNotification:localNoti];
}

-(void)keyBoardWillShow:(NSNotification *)not{
    NSDictionary *dict=not.userInfo;
    CGRect rect =[dict[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat time=[[dict objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    [UIView animateWithDuration:time animations:^(void)
     {
//         _textField.frame=CGRectMake(_textField.frame.origin.x, _textField.frame.origin.y-rect.size.height, _textField.frame.size.width, _textField.frame.size.height);
//         _sendButton.frame=CGRectMake(_sendButton.frame.origin.x, _sendButton.frame.origin.y-rect.size.height, _sendButton.frame.size.width, _sendButton.frame.size.height);
//         _tableView.frame=CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height-rect.size.height);
         self.view.transform=CGAffineTransformMakeTranslation(0, -rect.size.height);
     }completion:nil];
}
-(void)keyBoardWillMiss:(NSNotification *)not{
    NSDictionary *dict=not.userInfo;
//    CGRect rect =[dict[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat time=[[dict objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    [UIView animateWithDuration:time animations:^(void)
     {
//         _textField.frame=CGRectMake(_textField.frame.origin.x, _textField.frame.origin.y+rect.size.height, _textField.frame.size.width, _textField.frame.size.height);
//         _sendButton.frame=CGRectMake(_sendButton.frame.origin.x, _sendButton.frame.origin.y+rect.size.height, _sendButton.frame.size.width, _sendButton.frame.size.height);
//         _tableView.frame=CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height+rect.size.height);

         self.view.transform=CGAffineTransformMakeTranslation(0, 0);
     }completion:nil];
}
-(void)dealloc{
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reConnect:(GCDAsyncSocket *)sock{
    if (self.isConnectting == YES) {
        return;
    }
    self.isConnectting = YES;
    
    //开启定时任务，每隔段时间尝试重新连接一次
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 创建一个定时器(dispatch_source_t本质还是个OC对象)
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(3.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, start, interval, 0);
    // 设置回调
    dispatch_source_set_event_handler(self.timer, ^{
        NSLog(@"正在努力尝试重新链接。。。");
        
        //重新连接
        NSError *error=nil;
        [sock connectToHost:serverIp onPort:serverPort error:&error];
        if (!error) {
            NSLog(@"error--%@",error);
        }else{
            NSLog(@"重连成功");
            // 取消定时器
            dispatch_cancel(self.timer);
            self.timer = nil;
            self.isConnectting = NO;
        }
    });
    // 启动定时器
    dispatch_resume(self.timer);
}

#pragma mark---tableView的代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *model=self.dataArray[indexPath.row];
    UITableViewCell *cell=nil;
    if ([model.type isEqualToString:@"mine"]) {
        cell=[self createMineCellWithTableView:tableView indexPath:indexPath];
    }
    if ([model.type isEqualToString:@"other"]) {
        cell=[self createOtherCellWithTableView:tableView indexPath:indexPath];
    }
    cell.transform=CGAffineTransformMakeRotation(2*M_PI_2);
    return cell;
}
-(UITableViewCell *)createMineCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    MineMessageCell *cell=[tableView dequeueReusableCellWithIdentifier:@"MineMessageCellID"];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"MineMessageCell" owner:nil options:nil] lastObject];
        cell.backgroundColor=[UIColor clearColor];
    }
    MessageModel *model=self.dataArray[indexPath.row];
    cell.model=model;
    return cell;
}
-(UITableViewCell *)createOtherCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    MineMessageCell *cell=[tableView dequeueReusableCellWithIdentifier:@"OtherMessageCellID"];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"OtherMessageCell" owner:nil options:nil] lastObject];
        cell.backgroundColor=[UIColor clearColor];
    }
    MessageModel *model=self.dataArray[indexPath.row];
    cell.model=model;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *message=self.dataArray[indexPath.row];
    return message.cellHeight;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 200;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_textField resignFirstResponder];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
