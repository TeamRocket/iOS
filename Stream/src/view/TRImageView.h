//
//  TRImageView.h
//  Stream
//
//  Created by Peter Tsoi on 12/13/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TRImage.h"
#import "TRNetwork.h"

@interface TRImageView : UIImageView <TRConnectionDelegate> {
    TRImage * mImage;
    UIActivityIndicatorView * mSpinner;
}

- (id)initWithImage:(UIImage *)image;
- (id)initWithTRImage:(TRImage *)image inFrame:(CGRect)frame;
- (id)initWithURL:(NSURL *)url inFrame:(CGRect)frame;

- (void)setTRImage:(TRImage*)image;

@end
