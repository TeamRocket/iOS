//
//  TRGraph.m
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRGraph.h"

#import "TRAppDelegate.h"

#import "TRPhoto.h"
#import "TRPhotoStream.h"
#import "TRUser.h"

typedef enum {
    kTRGraphNetworkTaskDownloadUserPhotoStreams,
    kTRGraphNetworkTaskUserLogin,
} TRGraphNetworkTask;

@implementation TRGraph

- (id) init{
    self = [super init];
    if (self) {
        mActiveConnections = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                       0,
                                                       &kCFTypeDictionaryKeyCallBacks,
                                                       &kCFTypeDictionaryValueCallBacks);
        mDelegates = [[NSMutableArray alloc] init];
        mStreams = [[NSMutableDictionary alloc] init];
        mUsers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id) initWithDelegate:(id<TRGraphDelegate>)delegate {
    self = [self init];
    if (self) {
        mDelegates = [[NSMutableArray alloc] initWithObjects:delegate, nil];
    }
    return self;
}

- (void)registerForDelegateCallback:(id<TRGraphDelegate>)delegate {
    [mDelegates addObject:delegate];
}

- (void)unregisterForDelegateCallback:(id<TRGraphDelegate>)delegate {
    [mDelegates removeObject:delegate];
}

- (BOOL)updating {
    return CFDictionaryGetCount(mActiveConnections) > 0;
}

#pragma mark User 

- (void)loginAsUser:(NSString*)first password:(NSString*)password {
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"api/signin.php?first=%@&password=%@", first, password]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskUserLogin]);
}

- (void)p_receivedLoginResponse:(NSDictionary*)info {
    TRUser * user = [self getUserWithPhone:[info objectForKey:@"value"]];
    if (user == nil && ![[info objectForKey:@"value"] isEqualToString:@"false"] && ![[info objectForKey:@"value"] isEqualToString:@""]) {
        user = [[TRUser alloc] initWithPhone:[info objectForKey:@"value"] firstName:nil lastName:nil];
        [self addUser:user];
    }
    [[NSUserDefaults standardUserDefaults] setObject:user.phone forKey:@"user_phone"];
}

- (void)addUser:(TRUser*)user {
    if (![mUsers objectForKey:user.phone]) {
        [mUsers setValue:user forKey:user.phone];
    }
}

- (TRUser*)getUserWithPhone:(NSString*)phone {
    return [mUsers objectForKey:phone];
}

#pragma mark Photo

- (void)addPhoto:(TRPhoto*)photo {
    if (![mPhotos objectForKey:[photo.URL absoluteString]])
        [mPhotos setValue:photo forKey:[photo.URL absoluteString]];
}

- (TRPhoto*)getPhotoWithURL:(NSURL*)url {
    return [mPhotos objectForKey:[url absoluteString]];
}

#pragma mark Stream

- (void)addStream:(TRPhotoStream *)stream {
    if (![mStreams objectForKey:stream.ID])
        [mStreams setValue:stream forKey:stream.ID];
}

- (TRPhotoStream *)getStreamWithID:(NSString*)ID {
    return [mStreams objectForKey:ID];
}

- (void)downloadUserPhotoStreams:(NSString*)phone {
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"api/populateStreamNewsfeed.php?phone=%@", phone]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskDownloadUserPhotoStreams]);
}

- (void)p_downloadedUserPhotoStreams:(NSDictionary*)data {
    TRUser * loggedInUser = [self getUserWithPhone:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]];
    for (NSString * ID in data) {
        NSDictionary * streamData = [data objectForKey:ID];
        TRPhotoStream * newStream = [self getStreamWithID:ID];
        if (newStream == nil) {
            newStream = [[TRPhotoStream alloc] initWithID:ID name:[streamData objectForKey:@"streamName"]
                                             participants:[[streamData objectForKey:@"numberOfParticipants"] intValue]
                                                   photos:[[streamData objectForKey:@"numberOfPhotos"] intValue]];
            [self addStream:newStream];
        }
        TRPhoto * latestPhoto = [self getPhotoWithURL:[NSURL URLWithString:[streamData objectForKey:@"latestPicture"]]];
        if (latestPhoto == nil) {
            latestPhoto = [[TRPhoto alloc] initWithURL:[NSURL URLWithString:[streamData objectForKey:@"latestPicture"]]
                                              uploader:nil];
            [self addPhoto:latestPhoto];
        }
        [newStream addPhotoAsLatest:latestPhoto];
        [loggedInUser addStream:newStream];
    }
}

#pragma mark - TRConnectionDelegate

- (void) connection:(TRConnection *)connection finishedDownloadingData:(NSData *)data {
    if (CFDictionaryContainsKey(mActiveConnections, (__bridge const void *)connection)) {
        NSString * mode = CFDictionaryGetValue(mActiveConnections, (__bridge const void *)connection);
        NSMutableDictionary * info = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
        switch ([mode intValue]) {
            case kTRGraphNetworkTaskDownloadUserPhotoStreams:
                [self p_downloadedUserPhotoStreams:info];
                break;
            case kTRGraphNetworkTaskUserLogin:
                [self p_receivedLoginResponse:info];
                break;
            default:
                break;
        }
        CFDictionaryRemoveValue(mActiveConnections, (__bridge const void *)connection);
    }
    if (![self updating]) {
        for (id<TRGraphDelegate> delegate in [mDelegates copy]) {
            [delegate graphFinishedUpdating];
        }
    }
}

- (void) connection:(TRConnection *)connection failedWithError:(NSError *)error {
    if (CFDictionaryContainsKey(mActiveConnections, (__bridge const void *)connection))
        CFDictionaryRemoveValue(mActiveConnections, (__bridge const void *)connection);
    if (![self updating]) {
        for (id<TRGraphDelegate> delegate in [mDelegates copy]) {
            [delegate graphFinishedUpdating];
        }
    }
}

@end
