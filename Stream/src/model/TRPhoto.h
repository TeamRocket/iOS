//
//  TRPhoto.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TRUser;
@class TRImage;

@interface TRPhoto : NSObject {
    TRUser * mUploader;
    NSURL * mURL;
    NSString * mID;
    TRImage * mImage;

    int mNumLikes;
    int mNumComments;
    NSMutableArray * mLikers;
    NSMutableArray * mComments;
}

@property (nonatomic) TRUser * uploader;
@property (nonatomic, readonly) NSURL * URL;
@property (nonatomic, readonly) NSString * ID;
@property (nonatomic) TRImage * image;
@property (nonatomic) int numLikes;
@property (nonatomic) int numComments;
@property (nonatomic, readonly) NSArray * likers;
@property (nonatomic, readonly) NSArray * comments;

- (id) initWithID:(NSString*)ID URL:(NSURL*)url uploader:(TRUser*)uploader;
- (void)addLiker:(TRUser*)user;
- (void)removeLiker:(TRUser*)user;
- (void)addComment:(NSDictionary *)comment;

@end
