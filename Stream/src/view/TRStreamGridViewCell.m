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
    [mLeftFrame.layer setShadowColor:[UIColor blackColor].CGColor];
    [mLeftFrame.layer setShadowOpacity:0.5];
    [mLeftFrame.layer setShadowRadius:2.0];
    [mLeftFrame.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [mLeftFrame.layer setBorderColor:[UIColor whiteColor].CGColor];
    [mLeftFrame.layer setBorderWidth:5.0f];

    [mRightFrame.layer setShadowColor:[UIColor blackColor].CGColor];
    [mRightFrame.layer setShadowOpacity:0.5];
    [mRightFrame.layer setShadowRadius:2.0];
    [mRightFrame.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [mRightFrame.layer setBorderColor:[UIColor whiteColor].CGColor];
    [mRightFrame.layer setBorderWidth:5.0f];
}

@end
