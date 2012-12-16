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
@class TRImageView;

@interface TRPhotoViewController : UIViewController <TRGraphDelegate> {
    TRImageView * mImageView;
    TRPhoto * mPhoto;

    IBOutlet UILabel * mUploaderLabel;
    IBOutlet UIButton * mCloseButton;
    IBOutlet UIButton * mLikeButton;
    IBOutlet UILabel * mLikeCountLabel;

    UIView * mLikeOverlayView;
    UIImageView * mLikeIndicator;

    UIImageView * mLikeOverlayImage;
    UILabel * mLikeOverlayLabel;
}

- (void)setPhotoView:(TRImageView*)photoView;

@end
