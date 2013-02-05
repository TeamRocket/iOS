//
//  TRCommentCell.m
//  Stream
//
//  Created by Peter Tsoi on 1/23/13.
//  Copyright (c) 2013 TeamRocket. All rights reserved.
//

#import "TRCommentCell.h"

@implementation TRCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [mCommenterLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:15.0]];
    [mTimeLabel setFont:[UIFont fontWithName:@"MuseoSans-300" size:15.0]];
    mCommentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 300, 60)];
    [mCommentLabel setNumberOfLines:0];
    [mCommentLabel setShadowColor:[UIColor blackColor]];
    [mCommentLabel setFont:[UIFont fontWithName:@"MuseoSans-100" size:15.0]];
    [mCommentLabel setTextColor:[UIColor whiteColor]];
    [mCommentLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:mCommentLabel];
}

- (void)setComment:(NSString*)comment {
    [mCommentLabel setFrame:CGRectMake(10, 25, 300, 60)];
    [mCommentLabel setText:comment];
    [mCommentLabel sizeToFit];
}

- (void)setCommenter:(NSString*)commenter {
    [mCommenterLabel setText:commenter];
}

- (void)setTime:(NSString*)time {
    [mTimeLabel setText:time];
}

@end
