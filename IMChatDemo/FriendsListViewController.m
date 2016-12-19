//
//  FriendsListViewController.m
//  IMChatDemo
//
//  Created by lujiangbin on 15/10/14.
//  Copyright © 2015年 lujiangbin. All rights reserved.
//


#import "FriendsListViewController.h"
#import "JBXMPPManager.h"
#import "ChatViewController.h"
#import "GroupChatController.h"

@interface FriendsListViewController ()

//@property (nonatomic, strong) NSMutableArray    *friendsList;
//@property (nonatomic, strong) NSMutableArray    *groupsList;
@property (nonatomic, strong) NSMutableArray    *dataSource;

@end

@implementation FriendsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = [[JBXMPPManager sharedInstance] xmppStream].myJID.user;
    
    //监听好友变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rosterChange) name:@"RosterChanged" object:nil];
    
    //监听群组房间列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGroupList:) name:@"GroupListChaged" object:nil];
    
    //获取服务器好友列表
    [[[JBXMPPManager sharedInstance] xmppRoster] fetchRoster];
    
    //发现聊天室如果有聊天室并加入聊天室
    [[[JBXMPPManager sharedInstance] xmppMuc] discoverServices];
    
    self.dataSource = [NSMutableArray arrayWithCapacity:2];
    
}
- (IBAction)logOut:(id)sender {
    
    [[JBXMPPManager sharedInstance] logOut];
    [self performSegueWithIdentifier:@"Login" sender:self];
}

#pragma mark -- 更新好友

- (void)rosterChange
{
//    NSArray *friendsList = [NSArray arrayWithArray:[JBXMPPManager sharedInstance].xmppRosterMemoryStorage.unsortedUsers];
    NSArray *Friends = [JBXMPPManager sharedInstance].xmppRosterMemoryStorage.sortedUsersByName;
    if ([Friends count]>0) {
        self.dataSource[0] = Friends;
        [self.tableView reloadData];
    }
    

}

- (void)getGroupList:(NSNotification *)notification {
      
    self.dataSource[1] = [notification.userInfo objectForKey:@"roomNames"];
    [self.tableView reloadData];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.dataSource count];
}


- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (section == 0? @"家庭好友":@"家庭群聊");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.dataSource[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendsListCell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        XMPPUserMemoryStorageObject *user = self.dataSource[indexPath.section][indexPath.row];
        
        cell.imageView.image = [UIImage imageNamed:@"UserImage"];
        cell.textLabel.text = user.jid.user;
        
        if ([user isOnline])
        {
            cell.detailTextLabel.text = @"[在线]";
        } else
        {
            cell.detailTextLabel.text = @"[离线]";
        }

    }else{
        cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = @"";
    }
        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        ChatViewController *chatVC = [[ChatViewController alloc] init];
        XMPPUserMemoryStorageObject *user = self.dataSource[indexPath.section][indexPath.row];
        chatVC.chatJID = user.jid;
        [self.navigationController pushViewController:chatVC animated:YES];
    }else{
        GroupChatController *groupChatVC = [[GroupChatController alloc] init];
        groupChatVC.roomID = self.dataSource[indexPath.section][indexPath.row];
        [self.navigationController pushViewController:groupChatVC animated:YES];
    }
    
    
}


@end
