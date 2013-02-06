//
//  TRCommentCell.h
//  Stream
//
//  Created by Peter Tsoi on 1/23/13.
//  Copyright (c) 2013 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TRCommentCell : UITableViewCell {
    IBOutlet UILabel * mCommenterLabel;
    IBOutlet UILabel * mTimeLabel;
    UILabel * mCommentLabel;
}

- (void)setComment:(NSString*)comment;
- (void)setCommenter:(NSString*)commenter;
- (void)setTime:(NSString*)time;

@end
