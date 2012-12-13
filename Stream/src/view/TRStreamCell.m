//
//  TRStreamCell.m
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRStreamCell.h"

@implementation TRStreamCell

@synthesize imageView = mImageView;
@synthesize titleLabel = mTitleLabel;
@synthesize participantsLabel = mParticipantsLabel;
@synthesize photosLabel = mPhotosLabel;

- (void)setImage:(TRImage*)image {
    [mImageView removeFromSuperview];
    mImageView = [[TRImageView alloc] initWithTRImage:image
                                              inFrame:mImageView.frame];
    [self addSubview:mImageView];
}

@end
