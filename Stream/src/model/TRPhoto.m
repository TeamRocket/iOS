//
//  TRPhoto.m
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRPhoto.h"

#import "TRImage.h"
#import "TRUser.h"

@implementation TRPhoto

@synthesize uploader = mUploader;
@synthesize URL = mURL;
@synthesize ID = mID;
@synthesize image = mImage;
@synthesize numLikes = mNumLikes;
@synthesize likers = mLikers;

- (id) initWithID:(NSString*)ID URL:(NSURL*)url uploader:(TRUser*)uploader {
    self = [super init];
    if (self) {
        mUploader = uploader;
        mURL = url;
        mID = ID;

        mImage = [[TRImage alloc] initWithURL:mURL];
        mLikers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addLiker:(TRUser*)user {
    BOOL exists = NO;
    for (TRUser * liker in mLikers) {
        exists = exists || [liker.phone isEqualToString:user.phone];
    }
    if (!exists) {
        [mLikers addObject:user];
    }
}

- (void)removeLiker:(TRUser*)user {
    if ([mLikers containsObject:user]) {
        [mLikers removeObject:user];
    }
}

@end
