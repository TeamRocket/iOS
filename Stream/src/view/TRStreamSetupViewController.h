//
//  TRStreamSetupViewController.h
//  Stream
//
//  Created by Peter Tsoi on 12/19/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import <UIKit/UIKit.h>

#import "TRGraph.h"

#import "TRTokenField.h"

@class TRPhotoStream;
@class TRTextFieldCell;

typedef enum {
    kTRPhotoStreamSetupModeCreate,
    kTRPhotoStreamSetupModeInvite,
} TRPhotoStreamSetupMode;

@interface TRStreamSetupViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate, TRTokenFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, TRGraphDelegate> {
    UINavigationItem * mTitleItem;
    UIBarButtonItem * mCreateButton;
    IBOutlet UITableView * mTableView;
    NSMutableArray * mParticipants;
    TRTextFieldCell * mStreamNameField;
    TRPhotoStreamSetupMode mMode;
    TRPhotoStream * mStream;
}

- (id)initWithStream:(TRPhotoStream*)stream;

@end
