//
//  TRPhotoStream.m
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRPhotoStream.h"

#import "TRPhoto.h"
#import "TRUser.h"

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

- (void)addParticipant:(TRUser*)newUser {
    BOOL exists = NO;
    for (TRUser * user in mParticipants) {
        exists = exists || [newUser.phone isEqualToString:user.phone];
    }
    if (!exists) {
        [mParticipants addObject:newUser];
    }
}

- (void)addPhoto:(TRPhoto*)photo {
    if (![mPhotos containsObject:photo])
        [mPhotos addObject:photo];
}

- (void)addPhotoAsLatest:(TRPhoto*)photo {
    if ([mPhotos containsObject:photo]) {
        [mPhotos removeObject:photo];
    }
    [mPhotos insertObject:photo atIndex:0];
}

- (void)removePhoto:(TRPhoto*)photo {
    if ([mPhotos containsObject:photo])
        [mPhotos removeObject:photo];
}

- (TRPhoto*)photoBefore:(TRPhoto*)photo {
    int index = [mPhotos indexOfObject:photo];
    if (index == 0) {
        return nil;
    } else {
        return [mPhotos objectAtIndex:index-1];
    }
}

- (TRPhoto*)photoAfter:(TRPhoto*)photo {
    int index = [mPhotos indexOfObject:photo];
    if (index + 1 == [mPhotos count]) {
        return nil;
    } else {
        return [mPhotos objectAtIndex:index+1];
    }
}

- (TRPhoto *)searchForPhotoWithIDPrefix:(NSString*)prefix {
    for (TRPhoto * photo in mPhotos) {
        if ([[photo.ID substringToIndex:[prefix length]] isEqualToString:prefix]) {
            return photo;
        }
    }
    return nil;
}

@end
