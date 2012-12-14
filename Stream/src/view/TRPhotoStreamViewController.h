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

@interface TRPhotoStreamViewController : UIViewController <TRGraphDelegate, UITableViewDataSource, UITableViewDelegate> {
    TRPhotoStream * mStream;
    IBOutlet UITableView * mTableView;
}

- (id)initWithPhotoStream:(TRPhotoStream *)stream;

@end
