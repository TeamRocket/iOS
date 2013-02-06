//
//  TRStreamCell.m
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRStreamCell.h"

#import "TRImage.h"
#import "TRPhoto.h"

@implementation TRStreamCell

@synthesize imageView = mImageView;
@synthesize titleLabel = mTitleLabel;
@synthesize participantsLabel = mParticipantsLabel;
@synthesize photosLabel = mPhotosLabel;

- (void)setImage:(TRImage*)image {
    [mImageView removeFromSuperview];
    mImageView = [[TRImageView alloc] initWithTRImage:image
                                              inFrame:mImageView.frame];
    [self.contentView addSubview:mImageView];
}

- (void)setPhoto:(TRPhoto*)photo {
    mPhoto = photo;
    [mImageView removeFromSuperview];
    mImageView = [[TRImageView alloc] initWithTRPhoto:photo
                                              inFrame:mImageView.frame];
    [self.contentView addSubview:mImageView];
}

- (void)setBlankPhoto {
    mPhoto = nil;
    [mImageView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"empty_stream.png"]]];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [mImageView setBackgroundColor:[UIColor colorWithPatternImage:[mPhoto.image sizedTo:mImageView.frame.size]]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [mImageView setBackgroundColor:[UIColor colorWithPatternImage:[mPhoto.image sizedTo:mImageView.frame.size]]];
}

@end
