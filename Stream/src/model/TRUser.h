//
//  TRUser.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRUser : NSObject {
    NSString * mFirstName;
    NSString * mLastName;
    NSString * mPhone;
}

@property (nonatomic, readonly) NSString * firstName;
@property (nonatomic, readonly) NSString * lastName;
@property (nonatomic, readonly) NSString * phone;

- (id)initWithPhone:(NSString*)phone firstName:(NSString*)first lastName:(NSString*)last;

@end
