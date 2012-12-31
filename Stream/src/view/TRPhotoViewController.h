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

@interface TRPhotoViewController : UIViewController <TRGraphDelegate> {
    TRImageView * mImageView;
    TRImageView * mPrevView;
    TRImageView * mNextView;
    TRPhoto * mPhoto;
    TRPhoto * mPrevPhoto;
    TRPhoto * mNextPhoto;
    TRPhotoStream * mStream;

    IBOutlet UILabel * mUploaderLabel;
    IBOutlet UIButton * mCloseButton;
    IBOutlet UIButton * mLikeButton;
    IBOutlet UIButton * mLikeCountButton;

    UIView * mLikeOverlayView;
    UIImageView * mLikeIndicator;

    UIImageView * mLikeOverlayImage;
    UILabel * mLikeOverlayLabel;
}

- (void)setPhotoView:(TRImageView*)photoView;
- (void)setPrevPhoto:(TRPhoto*)prev;
- (void)setNextPhoto:(TRPhoto*)next;
- (void)setPhotoStream:(TRPhotoStream*)stream;

@end
