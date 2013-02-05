//
//  TRStreamViewController.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRGraph.h"

@class TRStreamTableViewController;

@interface TRStreamViewController : UINavigationController <TRGraphDelegate> {
    TRStreamTableViewController * mStreamTable;
    NSString * mJumpToStreamIDPrefix;
    NSString * mJumpToPhotoIDPrefix;
    BOOL * mComment;
}

- (void)jumpToStream:(NSString*)streamIDPrefix;

- (void)jumpToPhoto:(NSString*)photoIDPrefix inStream:(NSString*)streamIDPrefix comment:(BOOL)comment;

@end
