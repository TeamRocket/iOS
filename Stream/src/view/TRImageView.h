//
//  TRImageView.h
//  Stream
//
//  Created by Peter Tsoi on 12/13/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TRNetwork.h"

@class TRImage;
@class TRPhoto;

@interface TRImageView : UIImageView <TRConnectionDelegate> {
    TRImage * mImage;
    TRPhoto * mPhoto;
    TRConnection * mConnection;
    UIActivityIndicatorView * mSpinner;
    UITapGestureRecognizer * mTapRecognizer;
    CGSize mPostDownloadResize;
}

@property (nonatomic) UITapGestureRecognizer * tapRecognizer;
@property (nonatomic) TRPhoto * TRPhoto;

- (id)initWithImage:(UIImage *)image;
- (id)initWithTRImage:(TRImage *)image inFrame:(CGRect)frame;
- (id)initWithTRPhoto:(TRPhoto*)photo inFrame:(CGRect)frame;
- (id)initWithTRPhoto:(TRPhoto *)photo fitInFrame:(CGRect)frame;
- (id)initWithURL:(NSURL *)url inFrame:(CGRect)frame;

- (void)setTRImage:(TRImage*)image;
- (void)setTRPhoto:(TRPhoto*)photo;

- (void)setPlaceholder;

- (void)setPictureInnerShadow:(BOOL)shadow;

- (void)setSpinnerVisible:(BOOL)spinner;

@end
