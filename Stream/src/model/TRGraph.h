//
//  TRGraph.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TRNetwork.h"

@protocol TRGraphDelegate

- (void)graphFinishedUpdating;

@end

@class TRUser;
@class TRPhoto;
@class TRPhotoStream;

@interface TRGraph : NSObject <TRConnectionDelegate> {
    NSMutableArray * mDelegates;
    CFMutableDictionaryRef mActiveConnections;

    NSMutableDictionary * mStreams;
    NSMutableDictionary * mPhotos;
    NSMutableDictionary * mUsers;
}

- (id)initWithDelegate:(id<TRGraphDelegate>)delegate;
- (void)registerForDelegateCallback:(id<TRGraphDelegate>)delegate;
- (void)unregisterForDelegateCallback:(id<TRGraphDelegate>)delegate;

- (void)loginAsUser:(NSString*)first password:(NSString*)password;
- (void)signupWithPhone:(NSString*)phone first:(NSString*)first last:(NSString*)last password:(NSString*)password;
- (TRUser*)getUserWithPhone:(NSString*)phone;
- (TRPhoto*)getPhotoWithURL:(NSURL*)url;

- (void)downloadUserPhotoStreams:(NSString*)phone;
- (void)downloadStreamInfo:(NSString*)stream forPhone:(NSString*)phone;
- (void)downloadPhotoInfo:(NSString*)url;
- (void)sendLikePhoto:(NSString*)url forPhone:(NSString*)phone;
- (void)sendUnlikePhoto:(NSString*)url forPhone:(NSString*)phone;
- (void)uploadPhoto:(TRPhoto*)photo toStream:(TRPhotoStream*)stream;
- (void)downloadParticipantsInStream:(NSString*)streamID;

- (void)didReceiveMemoryWarning;

@end
