//
//  TRSignupViewController.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TRSignupViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    IBOutlet UINavigationBar * mNavBar;
    IBOutlet UIBarButtonItem * mBackBtn;
    IBOutlet UIBarButtonItem * mSignupBtn;
    IBOutlet UITableView * mTableView;

    UITextField * mActiveField;
}

@end
