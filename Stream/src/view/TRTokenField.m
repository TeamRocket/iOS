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
    
}

- (void)pressedAddButton {
    if (mDelegate) {
        [mDelegate pressedAddButton:self];
    }
}

@end
