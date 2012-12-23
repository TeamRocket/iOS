//
//  TRParticipantCell.m
//  Stream
//
//  Created by Peter Tsoi on 12/23/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRParticipantCell.h"

#import "TRUser.h"

@implementation TRParticipantCell

@synthesize user = mUser;

- (void)setUser:(TRUser *)user{
    mUser = user;
    mParticipantNameLabel.text = [NSString stringWithFormat:@"%@ %@", mUser.firstName, mUser.lastName];
}

- (void)setNumPhotos:(int)photos {
    if (photos == 1) {
        mPhotoCountLabel.text = @"1 photo";
    } else {
        mPhotoCountLabel.text = [NSString stringWithFormat:@"%i photos", photos];
    }

}

@end
