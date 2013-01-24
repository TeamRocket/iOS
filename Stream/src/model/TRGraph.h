//
//  TRGraph.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TRNetwork.h"

@protocol TRGraphDelegate <NSObject>

- (void)graphFinishedUpdating;

@optional

- (void)uploadedBytes:(int)bytesWritten ofExpected:(int)bytesExpected;

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

    NSDateFormatter * mDateFormatter;

    TRUser * mMe;
}

@property (nonatomic) TRUser * me;

- (id)initWithDelegate:(id<TRGraphDelegate>)delegate;
- (void)registerForDelegateCallback:(id<TRGraphDelegate>)delegate;
- (void)unregisterForDelegateCallback:(id<TRGraphDelegate>)delegate;

- (void)loginAsUser:(NSString*)phone password:(NSString*)password;
- (void)addUser:(TRUser*)user;
- (void)signupWithPhone:(NSString*)phone first:(NSString*)first last:(NSString*)last password:(NSString*)password;
- (TRUser*)getUserWithPhone:(NSString*)phone;
- (TRPhoto*)getPhotoWithID:(NSString*)ID;

- (void)downloadUserPhotoStreams:(NSString*)phone;
- (void)downloadStreamInfo:(NSString*)stream forPhone:(NSString*)phone;
- (void)downloadPhotoInfo:(NSString*)ID;
- (void)sendLikePhoto:(NSString*)ID forPhone:(NSString*)phone;
- (void)sendUnlikePhoto:(NSString*)ID forPhone:(NSString*)phone;
- (void)uploadPhoto:(TRPhoto*)photo toStream:(TRPhotoStream*)stream;
- (void)createStreamNamed:(NSString*)streamName forPhone:(NSString*)phone withParticipants:(NSArray*)participants;
- (void)downloadParticipantsInStream:(NSString*)streamID;
- (void)downloadUserPhotos:(NSString*)phone inStream:(NSString*)streamID;
- (void)downloadLikesForPhoto:(NSString*)ID;
- (void)sendInviteUsers:(NSArray*)invitees toStream:(NSString*)streamID;
- (void)registerPushToken:(NSString*)token forPhone:(NSString*)phone;
- (void)downloadUserStatus:(NSString*)phone;

- (void)didReceiveMemoryWarning;

@end
