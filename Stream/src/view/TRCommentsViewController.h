//
//  TRCommentsViewController.h
//  Stream
//
//  Created by Peter Tsoi on 1/23/13.
//  Copyright (c) 2013 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TRCommentsViewController : UIViewController <UITextViewDelegate> {
    IBOutlet UIButton * mSendButton;
    IBOutlet UIImageView * mBottomGradient;
    IBOutlet UILabel * mTitleLabel;
    IBOutlet UITextView * mCommentBox;
    IBOutlet UIView * mBlackBack;

    CGSize mKBSize;
    UIViewAnimationCurve mKBAnimationCurve;
    CGFloat mKBAnimationDuration;
    CGFloat mLastCommentBoxHeight;
}

@end
