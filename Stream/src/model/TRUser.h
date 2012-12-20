//
//  TRUser.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TRTokenField.h"

@class TRPhotoStream;

@interface TRUser : NSObject <TRTokenObject> {
    NSString * mFirstName;
    NSString * mLastName;
    NSString * mPhone;

    NSMutableArray * mStreams;
}

@property (nonatomic) NSString * firstName;
@property (nonatomic) NSString * lastName;
@property (nonatomic, readonly) NSString * phone;
@property (nonatomic, readonly) NSArray * streams;

- (id)initWithPhone:(NSString*)phone firstName:(NSString*)first lastName:(NSString*)last;

- (void)addStream:(TRPhotoStream*)stream;

@end
