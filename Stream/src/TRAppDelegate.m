//
//  TRAppDelegate.m
//  Stream
//
//  Created by Peter Tsoi on 11/27/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRAppDelegate.h"

#import "TRGraph.h"
#import "TRNetwork.h"

#import "TRSplashViewController.h"
#import "TRStreamViewController.h"

@implementation TRAppDelegate

@synthesize graph = mGraph;
@synthesize network = mNetwork;
@synthesize pushToken = mPushToken;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [Mixpanel sharedInstanceWithToken:@"b270f22f26f5edc1cbd5b3c0c811253a"];
    [TestFlight takeOff:@"c5a032ea808bb992ba0e2063fd719860_MTYwMTg0MjAxMi0xMi0xNSAwMjozNjo1My40MzM0MDM"];
    if (launchOptions != nil && [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    mGraph = [[TRGraph alloc] init];
    mNetwork = [[TRNetwork alloc] init];
    mSplash = [[TRSplashViewController alloc] initWithNibName:@"TRSplashViewController" bundle:nil];
    mStream = [[TRStreamViewController alloc] init];
    self.window.rootViewController = mStream;
    [self.window makeKeyAndVisible];
    [mStream presentViewController:mSplash animated:NO completion:nil];

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:( UIRemoteNotificationTypeAlert |
                                                                            UIRemoteNotificationTypeBadge |
                                                                            UIRemoteNotificationTypeSound )];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    mPushToken = [[deviceToken description] stringByReplacingOccurrencesOfString:@" " withString:@""];
    mPushToken = [mPushToken substringWithRange:NSMakeRange(1, mPushToken.length-2)];
    if ([[NSUserDefaults alloc] objectForKey:@"user_phone"] != nil && [NSNull null] != [[NSUserDefaults alloc] objectForKey:@"user_phone"]) {
        [mGraph registerPushToken:mPushToken forPhone:[[NSUserDefaults alloc] objectForKey:@"user_phone"]];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel.people identify:[[NSUserDefaults alloc] objectForKey:@"user_phone"]];
        [mixpanel.people addPushDeviceToken:deviceToken];
    }
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Push error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
