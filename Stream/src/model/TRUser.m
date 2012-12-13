//
//  TRUser.m
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRUser.h"

@implementation TRUser

@synthesize firstName = mFirstName;
@synthesize lastName = mLastName;
@synthesize phone = mPhone;

- (id)initWithPhone:(NSString*)phone firstName:(NSString*)first lastName:(NSString*)last {
    self = [super init];
    if (self) {
        mPhone = phone;
        mFirstName = first;
        mLastName = last;
    }
    return self;
}

@end
