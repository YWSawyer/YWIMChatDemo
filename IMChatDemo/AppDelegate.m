//
//  AppDelegate.m
//  IMChatDemo
//
//  Created by lujiangbin on 15/10/12.
//  Copyright © 2015年 lujiangbin. All rights reserved.
//

#import "AppDelegate.h"
#import "JBXMPPManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    /*
    UIBackgroundTaskIdentifier backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:backgroundTask];
    }];
    if (backgroundTask == UIBackgroundTaskInvalid) {
        NSLog(@"app 申请后台失败。。。");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSLog(@"app 申请后台时间：%f秒",application.backgroundTimeRemaining);
        for (int i=0; i<100; i++) {
            NSLog(@"下载任务完成了%d%%  app剩余时间：%f秒",i,application.backgroundTimeRemaining);// 转换成百分比
            
            // 暂停10秒模拟正在执行后台下载
            [NSThread sleepForTimeInterval:5];
        }
        NSLog(@"app 剩余时间：%f",application.backgroundTimeRemaining/60);
        [application endBackgroundTask:backgroundTask];
    });
     */

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[JBXMPPManager sharedInstance]logOut];
    
    
}

@end
