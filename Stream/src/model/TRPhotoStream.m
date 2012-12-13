//
//  TRPhotoStream.m
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRPhotoStream.h"

#import "TRPhoto.h"

@implementation TRPhotoStream

@synthesize ID = mID;
@synthesize name = mName;
@synthesize participants = mParticipants;
@synthesize photos = mPhotos;

@synthesize numParticipants = mNumParticipants;
@synthesize numPhotos = mNumPhotos;

- (id) initWithID:(NSString*)ID name:(NSString*)name participants:(int)participants photos:(int)photos {
    self = [super init];
    if (self) {
        mID = ID;
        mName = name;
        mParticipants = [[NSMutableArray alloc] initWithCapacity:participants];
        mPhotos = [[NSMutableArray alloc] initWithCapacity:photos];
        mNumParticipants = participants;
        mNumPhotos = photos;
    }
    return self;
}

- (void)addPhoto:(TRPhoto*)photo {
    if (![mPhotos containsObject:photo])
        [mPhotos addObject:photo];
}

- (void)addPhotoAsLatest:(TRPhoto*)photo {
    if ([mPhotos containsObject:photo]) {
        [mPhotos removeObject:photo];
        [mPhotos addObject:photo];
    } else
        [self addPhoto:photo];
}

@end
