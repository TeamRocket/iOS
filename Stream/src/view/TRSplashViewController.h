//
//  TRSplashViewController.h
//  Stream
//
//  Created by Peter Tsoi on 12/11/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TRLoginViewController;
@class TRSignupViewController;

@interface TRSplashViewController : UIViewController {
    IBOutlet UIImageView * mLogoView;
    IBOutlet UILabel * mTitleLabel;
    IBOutlet UILabel * mSubtitleLabel;
    IBOutlet UIButton * mSignupButton;
    IBOutlet UIButton * mSigninButton;

    TRLoginViewController * mLoginView;
    TRSignupViewController * mSignupView;
}

- (void)authenitcated;

@end
