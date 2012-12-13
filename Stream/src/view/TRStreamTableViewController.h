//
//  TRStreamTableViewController.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TRStreamTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView * mTableView;
}

@end
