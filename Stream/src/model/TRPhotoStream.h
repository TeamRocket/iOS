//
//  TRPhotoStream.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TRPhoto;

@interface TRPhotoStream : NSObject {
    NSMutableArray * mParticipants;
    NSMutableArray * mPhotos;
    NSString * mID;
    NSString * mName;
}

@property (nonatomic) NSString * ID;
@property (nonatomic) NSString * name;
@property (nonatomic, readonly) NSArray * photos;

- (id) initWithID:(NSString*)ID name:(NSString*)name participants:(int)participants photos:(int)photos;

- (void)addPhoto:(TRPhoto*)photo;
- (void)addPhotoAsLatest:(TRPhoto*)photo;

@end
