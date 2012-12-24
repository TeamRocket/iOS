//
//  TRLoginViewController.h
//  Stream
//
//  Created by Peter Tsoi on 12/11/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TRGraph.h"

@interface TRLoginViewController : UIViewController <TRGraphDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    IBOutlet UINavigationBar * mNavBar;
    IBOutlet UIBarButtonItem * mBackBtn;
    IBOutlet UIBarButtonItem * mSigninBtn;
    IBOutlet UITableView * mTableView;

    UITextField * mUsernameField;
    UITextField * mPasswordField;
}

@end
