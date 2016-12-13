//
//  LoginViewController.m
//  IMChatDemo
//
//  Created by lujiangbin on 15/10/12.
//  Copyright © 2015年 lujiangbin. All rights reserved.
//

#import "LoginViewController.h"
#import "JBXMPPManager.h"


#import "DDASLLogger.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"



@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:@"DIDLogIn" object:nil];
    _userName.text = @"weiyuan";
    _passWord.text = @"12345";
    
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:0xfff]; // TTY = Xcode console
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logIn:(id)sender
{
    NSString *username = _userName.text;
    NSString *password = _passWord.text;//12345
    
    
    if (!username || !password) {
        return;
    }
    [[JBXMPPManager sharedInstance] loginWithName:username andPassword:password];    

}

#pragma mark -- 登录成功

#pragma mark - notification event

- (void)loginSuccess
{
    [self performSegueWithIdentifier:@"DidLogIn" sender:self];
}

@end
