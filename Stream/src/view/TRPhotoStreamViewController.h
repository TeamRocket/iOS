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

@interface TRPhotoStreamViewController : UIViewController <TRGraphDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
    TRPhotoStream * mStream;
    IBOutlet UITableView * mTableView;
    UIRefreshControl * mRefreshControl;
    UIImagePickerController * mPicker;
}

- (id)initWithPhotoStream:(TRPhotoStream *)stream;

@end
