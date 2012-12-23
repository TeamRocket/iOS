//
//  TRParticipantsViewController.h
//  Stream
//
//  Created by Peter Tsoi on 12/23/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TRGraph.h"

@class TRPhotoStream;

@interface TRParticipantsViewController : UIViewController <TRGraphDelegate, UITableViewDataSource, UITableViewDelegate> {
    TRPhotoStream * mStream;
    IBOutlet UITableView * mTableView;
}

- (id)initWithStream:(TRPhotoStream*)stream;

@end
