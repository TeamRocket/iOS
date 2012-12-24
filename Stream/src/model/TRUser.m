//
//  TRUser.m
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRUser.h"

#import "TRPhotoStream.h"

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

        mStreams = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray*)streams {
    return [mStreams sortedArrayUsingComparator:^(id obj1, id obj2) {
        TRPhotoStream * stream1 = obj1;
        TRPhotoStream * stream2 = obj2;
        return [stream1.ID compare:stream2.ID];
    }];
}

- (void)addStream:(TRPhotoStream*)stream {
    if (![mStreams containsObject:stream])
        [mStreams addObject:stream];
}

- (NSString*)title {
    return [NSString stringWithFormat:@"%@ %@", mFirstName, mLastName];
}

@end
