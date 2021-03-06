//
//  RootViewController.m
//  UUChatTableView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "GroupChatController.h"
#import "UUInputFunctionView.h"
#import "MJRefresh.h"
#import "UUMessageCell.h"
#import "ChatModel.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"
#import "VoiceConverter.h"



@interface GroupChatController ()<UITableViewDelegate,UITableViewDataSource,UUInputFunctionViewDelegate,UUMessageCellDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) MJRefreshHeaderView *head;
@property (strong, nonatomic) ChatModel *chatModel;

@property (strong, nonatomic) UITableView *chatTableView;
@property (strong, nonatomic) NSLayoutConstraint *bottomConstraint;

@end

@implementation GroupChatController{
    UUInputFunctionView *IFView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我家客厅";
    [[JBXMPPManager sharedInstance] setCurrentChattingRoomId:self.roomID];
    self.chatTableView = [[UITableView alloc]init];
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatTableView.dataSource = self;
    self.chatTableView.delegate = self;
    [self.view addSubview:self.chatTableView];
    self.chatTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.chatTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-40];
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:self.chatTableView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.chatTableView
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0
                                                              constant:0],
                                [NSLayoutConstraint constraintWithItem:self.chatTableView
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1.0
                                                              constant:0],
                                self.bottomConstraint

                                ]];
    [self addRefreshViews];
    [self loadBaseViewsAndData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //add notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableViewScrollToBottom) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewsMessage:) name:DID_RECEIVE_GROUP_MESSAGE object:nil];

    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [[JBXMPPManager sharedInstance].xmppRoom leaveRoom];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)addRefreshViews
{
    __weak typeof(self) weakSelf = self;
    
    //load more
    int pageNum = 3;
    
    _head = [MJRefreshHeaderView header];
    _head.scrollView = self.chatTableView;
    _head.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
//                [weakSelf.chatModel addRandomItemsToDataSource:pageNum];
//        
//                if (weakSelf.chatModel.dataSource.count > pageNum) {
//                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:pageNum inSection:0];
//        
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        [weakSelf.chatTableView reloadData];
//                        [weakSelf.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
//                    });
//                }
        [weakSelf.head endRefreshing];
    };
}

- (void)loadBaseViewsAndData
{
    self.chatModel = [[ChatModel alloc]init];
    
    //从本地数据库获取历史消息
    [self.chatModel getMessageHistoryWithJID:[XMPPJID jidWithString:self.roomID]];
    
    IFView = [[UUInputFunctionView alloc]initWithSuperVC:self];
    IFView.delegate = self;
    [self.view addSubview:IFView];
    
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}

-(void)keyboardChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    //adjust ChatTableView's height
    if (notification.name == UIKeyboardWillShowNotification) {
        self.bottomConstraint.constant = -(keyboardEndFrame.size.height+40);
    }else{
        self.bottomConstraint.constant = -40;
    }
    
    [self.view layoutIfNeeded];
    
    //adjust UUInputFunctionView's originPoint
    CGRect newFrame = IFView.frame;
    newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height;
    IFView.frame = newFrame;
    
    [UIView commitAnimations];
    
}

//tableView Scroll to bottom
- (void)tableViewScrollToBottom
{
    if (self.chatModel.dataSource.count==0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

/**
 *  返回文件保存的路径
 *
 *  @return 文件路径
 */
-(NSString*)pathForFile:(NSString*)UUID
{
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"AudioAndImage"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *result = [path stringByAppendingPathComponent:UUID];
    
    return result;
}



-(void)handleNewsMessage:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    XMPPMessageArchiving_Message_CoreDataObject *recordMessage = userInfo[@"message"];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    
    NSString *myStr = @"http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg";
    NSString *otherStr =@"http://p1.qqyou.com/touxiang/uploadpic/2011-3/20113212244659712.jpg";
    
    //对方发的消息，显示在左边
    BOOL fromOthers = recordMessage.message.from;
    
    [dataDic setObject:fromOthers ? @(UUMessageFromOther):@(UUMessageFromMe) forKey:@"from"];
    [dataDic setObject:[recordMessage.timestamp description] forKey:@"strTime"];
    [dataDic setObject:fromOthers?recordMessage.message.from.resource:[JBXMPPManager sharedInstance].myJID.user forKey:@"strName"];
    [dataDic setObject:fromOthers ? otherStr:myStr forKey:@"strIcon"];
    
    
    //type:voice text picture
    NSNumber  *type;
    if ([recordMessage.message.subject isEqualToString:@"voice"]) {
        
        type = @(2);
        NSString *voicePath = [self pathForFile:recordMessage.body];
        [dataDic setObject:[NSData dataWithContentsOfFile:voicePath] forKey:@"voice"];
        [dataDic setObject:@([recordMessage.message attributeIntValueForName:@"VoiceLength"]) forKey:@"strVoiceTime"];
    }else if ([recordMessage.message.subject isEqualToString:@"picture"]){
        type = @(1);
        NSString *picturePath = [self pathForFile:recordMessage.body];
        [dataDic setObject:[UIImage imageWithContentsOfFile:picturePath] forKey:@"picture"];
        
    }else{
        type = @(0);
        [dataDic setObject:recordMessage.body forKey:@"strContent"];
    }
    
    
    [dataDic setObject:type forKey:@"type"];
    
    [self dealTheFunctionData:dataDic];
    
}


#pragma mark - InputFunctionViewDelegate
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message
{
    [[[JBXMPPManager sharedInstance] getRoomWithRoomJid:self.roomID] sendMessageWithBody:message];
    funcView.TextViewInput.text = @"";
}

//音频跟图片压缩后 base64编码
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image
{
    NSString* encodeData = [UIImageJPEGRepresentation(image, 1.0) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    XMPPMessage* message = [[XMPPMessage alloc] init];
    [message addBody:encodeData];
    [message addSubject:@"picture"];
    [[[JBXMPPManager sharedInstance] getRoomWithRoomJid:self.roomID] sendMessage:message];
}

- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    NSString* encodeData = [voice base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    XMPPMessage* message = [[XMPPMessage alloc] init];
    [message addBody:encodeData];
    [message addSubject:@"voice"];
    [message addAttributeWithName:@"VoiceLength" unsignedIntegerValue:second];
    [[[JBXMPPManager sharedInstance] getRoomWithRoomJid:self.roomID] sendMessage:message];
    
}

- (void)dealTheFunctionData:(NSDictionary *)dic
{
    [self.chatModel addSpecifiedItem:dic];
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}

#pragma mark - tableView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatModel.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UUMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell == nil) {
        cell = [[UUMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        cell.delegate = self;
    }
    [cell setMessageFrame:self.chatModel.dataSource[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.chatModel.dataSource[indexPath.row] cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark - cellDelegate
- (void)headImageDidClick:(UUMessageCell *)cell userId:(NSString *)userId{
    // headIamgeIcon is clicked
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:cell.messageFrame.message.strName message:@"headImage clicked" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
    [alert show];
}

@end
