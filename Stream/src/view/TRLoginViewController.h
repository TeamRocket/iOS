//
//  TRLoginViewController.h
//  Stream
//
//  Created by Peter Tsoi on 12/11/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TRLoginViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UINavigationBar * mNavBar;
    IBOutlet UIBarButtonItem * mBackBtn;
    IBOutlet UIBarButtonItem * mSigninBtn;
    IBOutlet UITableView * mTableView;
}

@end
