//
//  TRAppDelegate.h
//  Stream
//
//  Created by Peter Tsoi on 11/27/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TRSplashViewController;
@class TRStreamViewController;
@class TRGraph;
@class TRNetwork;

#define AppDelegate ((TRAppDelegate *)[[UIApplication sharedApplication] delegate])

@interface TRAppDelegate : UIResponder <UIApplicationDelegate> {
    TRSplashViewController * mSplash;
    TRStreamViewController * mStream;

    TRGraph * mGraph;
    TRNetwork * mNetwork;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TRGraph * graph;
@property (strong, nonatomic) TRNetwork * network;

@end
