//
//  TRStreamTableViewController.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TRGraph.h"

@interface TRStreamTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TRGraphDelegate> {
    IBOutlet UITableView * mTableView;
    UIRefreshControl * mRefreshControl;
    BOOL mWasPreviouslyCreatingStream;
    IBOutlet UIImageView * mNUX;
}

@end
