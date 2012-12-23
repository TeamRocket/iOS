//
//  TRTokenField.h
//  Stream
//
//  Created by Peter Tsoi on 12/19/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TRToken;
@class TRTokenField;

@protocol TRTokenFieldDelegate

- (void)pressedAddButton:(TRTokenField*)sender;

@end

@protocol TRTokenObject

- (NSString*)title;

@end

@interface TRTokenField : UIView {
    NSMutableArray * mTokens;
    id <TRTokenFieldDelegate> mDelegate;
}

@property (nonatomic) id <TRTokenFieldDelegate> delegate;

- (void)addTokenObject:(id<TRTokenObject>)object;

@end