//
//  TRPhotoViewController.h
//  Stream
//
//  Created by Peter Tsoi on 12/15/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TRGraph.h"

@class TRCommentsViewController;
@class TRPhoto;
@class TRPhotoStream;
@class TRImageView;

@interface TRPhotoViewController : UIViewController <TRGraphDelegate, UIAlertViewDelegate, UIScrollViewDelegate> {
    TRImageView * mImageView;
    TRImageView * mPrevView;
    TRImageView * mNextView;
    TRPhoto * mPhoto;
    TRPhoto * mPrevPhoto;
    TRPhoto * mNextPhoto;
    TRPhotoStream * mStream;
    TRCommentsViewController * mCommentsViewController;

    IBOutlet UILabel * mUploaderLabel;
    IBOutlet UIButton * mCloseButton;
    IBOutlet UIButton * mDeleteButton;
    IBOutlet UIButton * mLikeButton;
    IBOutlet UIButton * mLikeCountButton;
    IBOutlet UIButton * mCommentCountButton;
    IBOutlet UIScrollView * mScroller;

    UIView * mLikeOverlayView;
    UIImageView * mLikeIndicator;

    UIButton * mCommentButton;
    UIImageView * mCommentIndicator;

    UIImageView * mLikeOverlayImage;
    UILabel * mLikeOverlayLabel;

    int mCurrentIndex;
}
- (id)initWithPhoto:(TRPhoto*)photo inStream:(TRPhotoStream*)stream;

- (void)setPhotoView:(TRImageView*)photoView;
- (void)setPhotoStream:(TRPhotoStream*)stream;

@end
