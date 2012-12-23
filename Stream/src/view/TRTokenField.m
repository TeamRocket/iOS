//
//  TRTokenField.m
//  Stream
//
//  Created by Peter Tsoi on 12/19/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRTokenField.h"

@implementation TRTokenField

@synthesize delegate = mDelegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIButton * addToken = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-35.0f, (frame.size.height-35.0f)/2,
                                                                         35.0f, 35.0f)];
        [addToken setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
        [addToken setBackgroundImage:[UIImage imageNamed:@"add_token.png"] forState:UIControlStateNormal];
        [addToken addTarget:self action:@selector(pressedAddButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addToken];
    }
    return self;
}

- (void)addTokenObject:(id<TRTokenObject>)object {
    TRToken * newToken = [[TRToken alloc] initWithTokenObject:object];
    [self addSubview:newToken];
}

- (void)pressedAddButton {
    if (mDelegate) {
        [mDelegate pressedAddButton:self];
    }
}

@end

@implementation TRToken

#define TOKEN_PADDING 15.0f

- (id)initWithTokenObject:(id<TRTokenObject>)object {
    self = [self initWithTitle:[object title]];
    if (self) {
        mObject = object;
    }
    return self;
}

- (id)initWithTitle:(NSString*)title {
    CGSize labelSize = [title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f]];
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, labelSize.width + TOKEN_PADDING + 28.0f, 25.0f)];
    if (self) {
        mTitle = title;
        [self setTitle:[NSString stringWithFormat:@"   %@", mTitle] forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f]];
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self setBackgroundImage:[[UIImage imageNamed:@"token_container.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0f, 15.0f, 13.0f, 13.0f)] forState:UIControlStateNormal];
    }
    return self;
}

@end
