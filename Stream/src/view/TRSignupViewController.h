//
//  TRSignupViewController.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TRGraph.h"

@interface TRSignupViewController : UIViewController <TRGraphDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    IBOutlet UINavigationBar * mNavBar;
    IBOutlet UIBarButtonItem * mBackBtn;
    IBOutlet UIBarButtonItem * mSignupBtn;
    IBOutlet UITableView * mTableView;

    UITextField * mActiveField;
    UITextField * mFirstNameField;
    UITextField * mLastNameField;
    UITextField * mPhoneField;
    UITextField * mPasswordField;
    UITextField * mConfirmPasswordField;
}

@end
