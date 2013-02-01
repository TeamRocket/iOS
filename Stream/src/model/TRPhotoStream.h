//
//  TRPhotoStream.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TRPhoto;
@class TRUser;

@interface TRPhotoStream : NSObject {
    NSMutableArray * mParticipants;
    NSMutableArray * mPhotos;
    NSString * mID;
    NSString * mName;

    int mNumParticipants;
    int mNumPhotos;
}

@property (nonatomic) NSString * ID;
@property (nonatomic) NSString * name;
@property (nonatomic, readonly) NSArray * participants;
@property (nonatomic, readonly) NSArray * photos;

@property (nonatomic) int numParticipants;
@property (nonatomic) int numPhotos;

- (id) initWithID:(NSString*)ID name:(NSString*)name participants:(int)participants photos:(int)photos;

- (void)addPhoto:(TRPhoto*)photo;
- (void)addPhotoAsLatest:(TRPhoto*)photo;
- (void)removePhoto:(TRPhoto*)photo;

- (void)addParticipant:(TRUser*)newUser;

- (TRPhoto*)photoBefore:(TRPhoto*)photo;
- (TRPhoto*)photoAfter:(TRPhoto*)photo;

@end
