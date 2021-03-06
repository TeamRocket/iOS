//
//  TRCommentsViewController.h
//  Stream
//
//  Created by Peter Tsoi on 1/23/13.
//  Copyright (c) 2013 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TRGraph.h"

@class TRPhoto;

@interface TRCommentsViewController : UIViewController <TRGraphDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate> {
    IBOutlet UIButton * mBackButton;
    IBOutlet UIButton * mSendButton;
    IBOutlet UIImageView * mBottomGradient;
    IBOutlet UILabel * mTitleLabel;
    IBOutlet UITextView * mCommentBox;
    IBOutlet UIView * mBlackBack;
    IBOutlet UITableView * mCommentsTable;

    CGSize mKBSize;
    UIViewAnimationCurve mKBAnimationCurve;
    CGFloat mKBAnimationDuration;
    CGFloat mLastCommentBoxHeight;

    TRPhoto * mPhoto;
    BOOL mShouldFocus;
}

- (void)setPhoto:(TRPhoto*)photo;
- (void)focus;

@end
