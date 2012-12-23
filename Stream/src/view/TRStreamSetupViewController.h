//
//  TRStreamSetupViewController.h
//  Stream
//
//  Created by Peter Tsoi on 12/19/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import <UIKit/UIKit.h>

#import "TRTokenField.h"

@class TRTextFieldCell;

@interface TRStreamSetupViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, TRTokenFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    IBOutlet UIBarButtonItem * mCreateButton;

    IBOutlet UITableView * mTableView;
    TRTokenField * mUsersField;
    NSMutableArray * mParticipants;
    TRTextFieldCell * mStreamNameField;
}

@end
