//
//  TRLikerListViewController.h
//  Stream
//
//  Created by Peter Tsoi on 12/24/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TRPhoto;

@interface TRLikerListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView * mTableView;
    TRPhoto * mPhoto;
}

- (id)initWithPhoto:(TRPhoto*)photo;

@end
