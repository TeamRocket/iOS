//
//  TRStreamGridViewCell.m
//  Stream
//
//  Created by Peter Tsoi on 12/14/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TRStreamGridViewCell.h"

#import "TRImageView.h"
#import "TRPhoto.h"

@implementation TRStreamGridViewCell

@synthesize leftFrame = mLeftFrame;
@synthesize rightFrame = mRightFrame;

- (void)awakeFromNib {
    [mLeftFrame setPictureInnerShadow:YES];
    [mLeftFrame setPlaceholder];
    [mRightFrame setPictureInnerShadow:YES];
    [mRightFrame setPlaceholder];
}

@end
