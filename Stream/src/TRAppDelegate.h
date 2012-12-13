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

@interface TRAppDelegate : UIResponder <UIApplicationDelegate> {
    TRSplashViewController * mSplash;
    TRStreamViewController * mStream;
}

@property (strong, nonatomic) UIWindow *window;

@end
