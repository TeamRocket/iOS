//
//  TRPhotoStreamViewController.h
//  Stream
//
//  Created by Peter Tsoi on 12/13/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TRGraph.h"

@class TRPhotoStream;

typedef enum {
    kTRPhotoStreamViewModeAll,
    kTRPhotoStreamViewModeUserFilter,
} TRPhotoStreamViewMode;

@interface TRPhotoStreamViewController : UIViewController <TRGraphDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
    TRPhotoStream * mStream;
    IBOutlet UITableView * mTableView;
    UIRefreshControl * mRefreshControl;
    UIImagePickerController * mPicker;
    TRPhotoStreamViewMode mMode;
    TRUser * mUser;
    BOOL mUploading;
}

- (id)initWithPhotoStream:(TRPhotoStream *)stream;
- (id)initWithPhotoStream:(TRPhotoStream *)stream mode:(TRPhotoStreamViewMode)mode;
- (id)initWithPhotoStream:(TRPhotoStream *)stream forUser:(TRUser*)user;

@end
