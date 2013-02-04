//
//  TRStreamViewController.m
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRStreamViewController.h"

#import "TRAppDelegate.h"
#import "TRPhotoStream.h"
#import "TRUser.h"

#import "TRPhotoStreamViewController.h"
#import "TRPhotoViewController.h"
#import "TRStreamTableViewController.h"

@interface TRStreamViewController ()

@end

@implementation TRStreamViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mStreamTable = [[TRStreamTableViewController alloc] initWithNibName:@"TRStreamTableViewController" bundle:nil];
        [self pushViewController:mStreamTable animated:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbarbg.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"MuseoSans-300" size:22.0], UITextAttributeFont, nil]];

    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@"navbarback.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@"navbarback_highlighted.png"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(5.0f, 0.0f) forBarMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"MuseoSans-500" size:11.0], UITextAttributeFont, nil] forState:UIControlStateNormal];

    [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"navbaritem.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"navbaritem_highlighted.png"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"MuseoSans-500" size:11.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
}

- (void)jumpToStream:(NSString*)streamIDPrefix {
    if (streamIDPrefix != nil) {
        TRPhotoStream * stream = [AppDelegate.graph searchForStreamWithIDPrefix:streamIDPrefix];
        if (stream == nil) {
            mJumpToStreamIDPrefix = streamIDPrefix;
            mJumpToPhotoIDPrefix = nil;
            [AppDelegate.graph downloadUserPhotoStreams:AppDelegate.graph.me.phone];
        } else {
            mJumpToStreamIDPrefix = nil;
            mJumpToPhotoIDPrefix = nil;
            [AppDelegate.graph unregisterForDelegateCallback:self];
            TRPhotoStreamViewController * streamController = [[TRPhotoStreamViewController alloc] initWithPhotoStream:stream];
            [self popToRootViewControllerAnimated:NO];
            [self pushViewController:streamController animated:NO];
        }
    }
}

- (void)jumpToPhoto:(NSString*)photoIDPrefix inStream:(NSString*)streamIDPrefix {
    if (streamIDPrefix != nil) {
        TRPhotoStream * stream = [AppDelegate.graph searchForStreamWithIDPrefix:streamIDPrefix];
        if (stream == nil) {
            mJumpToPhotoIDPrefix = photoIDPrefix;
            mJumpToStreamIDPrefix = streamIDPrefix;
            [AppDelegate.graph registerForDelegateCallback:self];
            [AppDelegate.graph downloadUserPhotoStreams:AppDelegate.graph.me.phone];
        } else {
            TRPhoto * photo = [stream searchForPhotoWithIDPrefix:photoIDPrefix];
            if (photo == nil) {
                mJumpToPhotoIDPrefix = photoIDPrefix;
                mJumpToStreamIDPrefix = streamIDPrefix;
                [AppDelegate.graph registerForDelegateCallback:self];
                [AppDelegate.graph downloadStreamInfo:stream.ID forPhone:AppDelegate.graph.me.phone];
            } else {
                mJumpToStreamIDPrefix = nil;
                mJumpToPhotoIDPrefix = nil;
                [AppDelegate.graph unregisterForDelegateCallback:self];
                TRPhotoStreamViewController * streamController = [[TRPhotoStreamViewController alloc] initWithPhotoStream:stream];
                TRPhotoViewController * photoView = [[TRPhotoViewController alloc] initWithPhoto:photo inStream:stream];
                [self popToRootViewControllerAnimated:NO];
                [self setNavigationBarHidden:YES animated:NO];
                [self pushViewController:streamController animated:NO];
                [self pushViewController:photoView animated:NO];
            }
        }
    }
}

- (void)graphFinishedUpdating {
    if (mJumpToStreamIDPrefix && mJumpToPhotoIDPrefix) {
        [self jumpToPhoto:mJumpToPhotoIDPrefix inStream:mJumpToStreamIDPrefix];
    } if (mJumpToStreamIDPrefix && mJumpToPhotoIDPrefix == nil) {
        [self jumpToStream:mJumpToStreamIDPrefix];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [AppDelegate.graph didReceiveMemoryWarning];
}

@end
