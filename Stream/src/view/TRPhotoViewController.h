//
//  TRPhotoViewController.h
//  Stream
//
//  Created by Peter Tsoi on 12/15/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TRGraph.h"

@class TRPhoto;
@class TRPhotoStream;
@class TRImageView;

@interface TRPhotoViewController : UIViewController <TRGraphDelegate, UIScrollViewDelegate> {
    TRImageView * mImageView;
    TRImageView * mPrevView;
    TRImageView * mNextView;
    TRPhoto * mPhoto;
    TRPhoto * mPrevPhoto;
    TRPhoto * mNextPhoto;
    TRPhotoStream * mStream;

    IBOutlet UILabel * mUploaderLabel;
    IBOutlet UIButton * mCloseButton;
    IBOutlet UIButton * mDeleteButton;
    IBOutlet UIButton * mLikeButton;
    IBOutlet UIButton * mLikeCountButton;
    IBOutlet UIScrollView * mScroller;

    UIView * mLikeOverlayView;
    UIImageView * mLikeIndicator;

    UIImageView * mLikeOverlayImage;
    UILabel * mLikeOverlayLabel;

    int mCurrentIndex;
}

- (void)setPhotoView:(TRImageView*)photoView;
- (void)setPhotoStream:(TRPhotoStream*)stream;

@end
