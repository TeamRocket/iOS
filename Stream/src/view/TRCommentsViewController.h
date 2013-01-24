//
//  TRCommentsViewController.h
//  Stream
//
//  Created by Peter Tsoi on 1/23/13.
//  Copyright (c) 2013 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TRPhoto;

@interface TRCommentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate> {
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
}

- (void)setPhoto:(TRPhoto*)photo;

@end
