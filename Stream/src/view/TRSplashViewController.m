//
//  TRSplashViewController.m
//  Stream
//
//  Created by Peter Tsoi on 12/11/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRSplashViewController.h"

#import "TRLoginViewController.h"
#import "TRSignupViewController.h"

@interface TRSplashViewController ()

@end

@implementation TRSplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)presentLogin:(id)sender {
    if (!mLoginView)
        mLoginView = [[TRLoginViewController alloc] initWithNibName:@"TRLoginViewController" bundle:nil];
    
    [self presentViewController:mLoginView animated:YES completion:nil];
}

- (IBAction)presentSignup:(id)sender {
    if (!mSignupView) {
        mSignupView = [[TRSignupViewController alloc] initWithNibName:@"TRSignupViewController" bundle:nil];
    }
    [self presentViewController:mSignupView animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [mSignupButton setBackgroundImage:[[UIImage imageNamed:@"orangebutton_normal.png"]
                                       resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)]
                             forState:UIControlStateNormal];
    [mSignupButton setBackgroundImage:[[UIImage imageNamed:@"orangebutton_pressed.png"]
                                       resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)]
                             forState:UIControlStateHighlighted];
    [mSignupButton.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-700" size:17.0f]];
    [mSigninButton setBackgroundImage:[[UIImage imageNamed:@"blackbutton_normal.png"]
                                       resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)]
                             forState:UIControlStateNormal];
    [mSigninButton setBackgroundImage:[[UIImage imageNamed:@"blackbutton_pressed.png"]
                                       resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)]
                             forState:UIControlStateHighlighted];
    [mSigninButton.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-700" size:17.0f]];

    [mTitleLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:40.0f]];
    [mSubtitleLabel setFont:[UIFont fontWithName:@"MuseoSans-300" size:17.0f]];

    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-568h"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self presentedViewController] != mLoginView)
        mLoginView = nil;
    if ([self presentedViewController] != mSignupView) {
        mSignupView = nil;
    }
}

@end
