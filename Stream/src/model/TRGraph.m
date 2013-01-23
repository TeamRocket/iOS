//
//  TRGraph.m
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRGraph.h"

#import "TRAppDelegate.h"

#import "TRImage.h"
#import "TRPhoto.h"
#import "TRPhotoStream.h"
#import "TRUser.h"

typedef enum {
    kTRGraphNetworkTaskDownloadUserPhotoStreams,
    kTRGraphNetworkTaskUserLogin,
    kTRGraphNetworkTaskUserSignup,
    kTRGraphNetworkTaskDownloadStreamInfo,
    kTRGraphNetworkTaskDownloadPhotoInfo,
    kTRGraphNetworkTaskSendLikePhoto,
    kTRGraphNetworkTaskSendUnlikePhoto,
    kTRGraphNetworkTaskUploadPhoto,
    kTRGraphNetworkTaskCreateStream,
    kTRGraphNetworkTaskDownloadParticipants,
    kTRGraphNetworkTaskDownloadUserPhotos,
    kTRGraphNetworkTaskDownloadLikes,
    kTRGraphNetworkTaskSendInvite,
    kTRGraphNetworkTaskRegisterPushToken,
    kTRGraphNetworkTaskGetUserStatus,
} TRGraphNetworkTask;

@implementation NSString (encode)
- (NSString *)encodeString:(NSStringEncoding)encoding
{
    return (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self,
                                                                NULL, (CFStringRef)@";/!?:@&=$+{}<>,.^*()",
                                                                CFStringConvertNSStringEncodingToEncoding(encoding));
}  
@end

@implementation TRGraph

@synthesize me = mMe;

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
        mPhotos = [[NSMutableDictionary alloc] init];
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
    if (![mDelegates containsObject:delegate]) {
        [mDelegates addObject:delegate];
    }
}

- (void)unregisterForDelegateCallback:(id<TRGraphDelegate>)delegate {
    if ([mDelegates containsObject:delegate]) {
        [mDelegates removeObject:delegate];
    }
}

- (BOOL)updating {
    return CFDictionaryGetCount(mActiveConnections) > 0;
}

#pragma mark User 

- (void)loginAsUser:(NSString*)phone password:(NSString*)password {
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"stream/1.0/api/sign_in.php?viewer_phone=%@&password=%@", [phone encodeString:NSASCIIStringEncoding], [password encodeString:NSASCIIStringEncoding]]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskUserLogin]);
}

- (void)signupWithPhone:(NSString*)phone first:(NSString*)first last:(NSString*)last password:(NSString*)password {
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"stream/1.0/api/sign_up.php?viewer_first=%@&viewer_last=%@&viewer_phone=%@&password=%@",
                                                                               [first encodeString:NSASCIIStringEncoding],
                                                                               [last encodeString:NSASCIIStringEncoding],
                                                                               [phone encodeString:NSASCIIStringEncoding],
                                                                               [password encodeString:NSASCIIStringEncoding]]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskUserSignup]);
}

- (void)p_receivedLoginResponse:(NSDictionary*)info {
    if (info && [[info objectForKey:@"status"] isEqualToString:@"ok"]) {
        TRUser * user = [self getUserWithPhone:[info objectForKey:@"viewer_phone"]];
        if (user == nil) {
            user = [[TRUser alloc] initWithPhone:[info objectForKey:@"viewer_phone"]
                                       firstName:[info objectForKey:@"viewer_first"]
                                        lastName:[info objectForKey:@"viewer_last"]];
            [self addUser:user];
        }
        mMe = user;
        [[NSUserDefaults standardUserDefaults] setObject:user.phone forKey:@"user_phone"];
        [[NSUserDefaults standardUserDefaults] setObject:user.firstName forKey:@"user_first"];
        [[NSUserDefaults standardUserDefaults] setObject:user.lastName forKey:@"user_last"];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_phone"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_first"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_last"];
    }
}

- (void)p_receivedSignupResponse:(NSDictionary*)info {
    [self p_receivedLoginResponse:info];
}

- (void)addUser:(TRUser*)user {
    if (![mUsers objectForKey:user.phone]) {
        [mUsers setValue:user forKey:user.phone];
    }
}

- (void)removeUser:(TRUser*)user {
    if ([mUsers objectForKey:user.phone]) {
        [mUsers removeObjectForKey:user.phone];
    }
}

- (TRUser*)getUserWithPhone:(NSString*)phone {
    return [mUsers objectForKey:phone];
}

- (void)registerPushToken:(NSString*)token forPhone:(NSString*)phone {
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"stream/1.0/api/register_push_token.php?viewer_phone=%@&token=%@", phone, token]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskRegisterPushToken]);
}

- (void)downloadUserStatus:(NSString*)phone {
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"api/isInBeta.php?phone=%@", phone]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskGetUserStatus]);
}

- (void)p_downloadedUserStatus:(NSDictionary*)info {
    if (info) {
        NSString * phone = [info objectForKey:@"phone"];
        if (phone != nil) {
            if ([[info objectForKey:@"isInBeta"] intValue] == 0) {
                [self removeUser:[self getUserWithPhone:phone]];
            }
        }
    }
}


#pragma mark Photo

- (void)sendLikePhoto:(NSString*)ID forPhone:(NSString*)phone{
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"stream/1.0/api/like_picture.php?liker_phone=%@&picture_id=%@", phone, ID]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskSendLikePhoto]);
}

- (void)sendUnlikePhoto:(NSString*)ID forPhone:(NSString*)phone{
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"stream/1.0/api/unlike_picture.php?liker_phone=%@&picture_id=%@", phone, ID]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskSendUnlikePhoto]);
}

- (void)downloadPhotoInfo:(NSString*)ID {
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"stream/1.0/api/get_picture_metadata.php?viewer_phone=%@&picture_id=%@",mMe.phone, ID]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskDownloadPhotoInfo]);
}

- (void)p_downloadedPhotoInfo:(NSDictionary*)info {
    if (info && [[info objectForKey:@"status"] isEqualToString:@"ok"]) {
        TRPhoto * photo = [self getPhotoWithID:[info objectForKey:@"picture_id"]];
        if (!photo) {
            photo = [[TRPhoto alloc] initWithID:[info objectForKey:@"picture_id"]
                                            URL:[NSURL URLWithString:[info objectForKey:@"picture_url"]]
                                       uploader:nil];
            [self addPhoto:photo];
        }
        if ([info objectForKey:@"uploader_phone"]) {
            TRUser * user = [self getUserWithPhone:[info objectForKey:@"uploader_phone"]];
            if (user == nil) {
                user = [[TRUser alloc] initWithPhone:[info objectForKey:@"uploader_phone"]
                                           firstName:[info objectForKey:@"uploader_first"]
                                            lastName:[info objectForKey:@"uploader_last"]];
                [self addUser:user];
            } else {
                user.firstName = [info objectForKey:@"uploader_first"];
                user.lastName = [info objectForKey:@"uploader_last"];
            }
            photo.uploader = user;
        }
        photo.numLikes = [[info objectForKey:@"picture_likecount"] intValue];
    }
}

- (void)addPhoto:(TRPhoto*)photo {
    if (![mPhotos objectForKey:photo.ID])
        [mPhotos setValue:photo forKey:photo.ID];
}

- (TRPhoto*)getPhotoWithID:(NSString*)ID {
    return [mPhotos objectForKey:ID];
}

- (void)uploadPhoto:(TRPhoto*)photo toStream:(TRPhotoStream*)stream {
    if (photo.uploader.phone && photo.image && stream.ID) {
        NSDictionary * args = [NSDictionary dictionaryWithObjectsAndKeys:
                               photo.uploader.phone, @"uploader_phone",
                               stream.ID, @"stream_id",
                               nil];
        TRConnection * conn = [AppDelegate.network postToURL:[NSURL URLWithString:@"stream/1.0/api/upload_file.php"
                                                                    relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]]
                                                   arguments:args
                                                        data:UIImageJPEGRepresentation((UIImage*)photo.image, 0.75)
                                                    delegate:self];
        CFDictionaryAddValue(mActiveConnections,
                             (__bridge const void *)conn,
                             (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskUploadPhoto]);
    }
}

- (void) p_uploadedPhoto:(NSDictionary*)info {
    NSLog(@"Uploaded photo");
    for (NSString * key in info) {
        NSLog(@"Key: %@,\t Value: %@", key, [info objectForKey:key]);
    }
}

- (void)downloadUserPhotos:(NSString*)phone inStream:(NSString*)streamID {
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"stream/1.0/api/get_pictures_uploaded_by_user.php?viewer_phone=%@&uploader_phone=%@&stream_id=%@", mMe.phone, phone, streamID]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskDownloadUserPhotos]);
}

- (void)p_downloadedUserPhotos:(NSDictionary*)info {
    if (info && [[info objectForKey:@"status"] isEqualToString:@"ok"]) {
        TRPhotoStream * stream = [self getStreamWithID:[info objectForKey:@"stream_id"]];
        if (stream != nil) {
            TRUser * user = [self getUserWithPhone:[info objectForKey:@"uploader_phone"]];
            if (user == nil) {
                user = [[TRUser alloc] initWithPhone:[info objectForKey:@"uploader_phone"]
                                           firstName:nil lastName:nil];
                [self addUser:user];
            }
            NSArray * photos = [info objectForKey:@"pictures"];
            for (NSDictionary * photoInfo in photos) {
                TRPhoto * photo = [self getPhotoWithID:[photoInfo objectForKey:@"picture_id"]];
                if (photo == nil) {
                    photo = [[TRPhoto alloc] initWithID:[photoInfo objectForKey:@"picture_id"]
                                                    URL:[NSURL URLWithString:[photoInfo objectForKey:@"picture_tinyurl"]]
                                               uploader:user];
                    [self addPhoto:photo];
                    [stream addPhoto:photo];
                }
                [user addPhoto:photo toStream:stream];
            }
        }
    }
}

- (void)downloadLikesForPhoto:(NSString*)ID {
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"stream/1.0/api/get_users_who_like.php?picture_id=%@", ID]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskDownloadLikes]);
}

- (void)p_downloadedLikes:(NSDictionary*)info {
    if (info != nil) {
        TRPhoto * photo = [self getPhotoWithID:[info objectForKey:@"picture_id"]];
        NSArray * likers = [info objectForKey:@"likers"];
        if (photo != nil) {
            for (NSDictionary * likerInfo in likers) {
                TRUser * user = [self getUserWithPhone:[likerInfo objectForKey:@"liker_phone"]];
                if (user == nil) {
                    user = [[TRUser alloc] initWithPhone:[likerInfo objectForKey:@"liker_phone"]
                                               firstName:[likerInfo objectForKey:@"liker_first"]
                                                lastName:[likerInfo objectForKey:@"liker_last"]];
                    [self addUser:user];
                }
                [photo addLiker:user];
            }
        }
    }
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
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"stream/1.0/api/populate_user_streams.php?viewer_phone=%@", phone]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskDownloadUserPhotoStreams]);
}

- (void)p_downloadedUserPhotoStreams:(NSDictionary*)info {
    if (info && [[info objectForKey:@"status"] isEqualToString:@"ok"]) {
        NSArray * streamInfos = [info objectForKey:@"streams"];
        for (NSDictionary * streamInfo in streamInfos) {
            TRPhotoStream * newStream = [self getStreamWithID:[streamInfo objectForKey:@"stream_id"]];
            if (newStream == nil) {
                newStream = [[TRPhotoStream alloc] initWithID:[streamInfo objectForKey:@"stream_id"]
                                                         name:[streamInfo objectForKey:@"stream_name"]
                                                 participants:[[streamInfo objectForKey:@"stream_usercount"] intValue]
                                                       photos:[[streamInfo objectForKey:@"picture_count"] intValue]];
                [self addStream:newStream];
            } else {
                newStream.name = [streamInfo objectForKey:@"stream_name"];
                newStream.numParticipants = [[streamInfo objectForKey:@"stream_usercount"] intValue];
                newStream.numPhotos = [[streamInfo objectForKey:@"picture_count"] intValue];
            }
            NSDictionary * latestPictureInfo = [streamInfo objectForKey:@"picture_latest"];
            if (![[NSNull null] isEqual:latestPictureInfo]) {
                TRPhoto * latestPhoto = [self getPhotoWithID:[latestPictureInfo objectForKey:@"picture_id"]];
                if (latestPhoto == nil) {
                    latestPhoto = [[TRPhoto alloc] initWithID:[latestPictureInfo objectForKey:@"picture_id"]
                                                          URL:[NSURL URLWithString:[latestPictureInfo objectForKey:@"picture_tinyurl"]]
                                                     uploader:nil];
                    [self addPhoto:latestPhoto];
                }
                [newStream addPhotoAsLatest:latestPhoto];
            }
            [mMe addStream:newStream];
        }
    }
}

- (void)downloadStreamInfo:(NSString*)stream forPhone:(NSString*)phone {
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"stream/1.0/api/populate_stream_profile.php?viewer_phone=%@&stream_id=%@", phone, stream]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskDownloadStreamInfo]);
}

- (void)p_downloadedStreamInfo:(NSDictionary*)info {
    if (info && [[info objectForKey:@"status"] isEqualToString:@"ok"]) {
        TRPhotoStream * stream = [self getStreamWithID:[info objectForKey:@"stream_id"]];
        if (stream != nil) {
            NSArray * pictures = [info objectForKey:@"pictures"];
            for (NSDictionary * photoInfo in [pictures reverseObjectEnumerator]) {
                if (photoInfo) {
                    TRPhoto * newPhoto = [self getPhotoWithID:[photoInfo objectForKey:@"picture_id"]];
                    if (newPhoto == nil) {
                        newPhoto = [[TRPhoto alloc] initWithID:[photoInfo objectForKey:@"picture_id"]
                                                           URL:[NSURL URLWithString:[photoInfo objectForKey:@"picture_tinyurl"]]
                                                      uploader:nil];
                        [self addPhoto:newPhoto];
                    }
                    [stream addPhotoAsLatest:newPhoto];
                    stream.numPhotos = [stream.photos count];
                }
            }
            if ([pictures count] > 0) {
                [stream addPhotoAsLatest: [self getPhotoWithID:[[pictures objectAtIndex:0] objectForKey:@"picture_id"]]];
            }
        }
        [stream setName:[info objectForKey:@"stream_name"]];
    }
}

- (void)createStreamNamed:(NSString*)streamName forPhone:(NSString*)phone withParticipants:(NSArray*)participants {
    NSString * participantCSV = [participants componentsJoinedByString:@","];
    NSMutableString *strippedString = [NSMutableString
                                       stringWithCapacity:participantCSV.length];

    NSScanner *scanner = [NSScanner scannerWithString:participantCSV];
    NSCharacterSet *numbers = [NSCharacterSet
                               characterSetWithCharactersInString:@"0123456789,"];
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];

        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"stream/1.0/api/create_stream.php?inviter_phone=%@&invitees_phone=%@&stream_name=%@", phone, strippedString, [streamName encodeString:NSASCIIStringEncoding]]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskCreateStream]);
}

- (void)p_createdStream:(NSDictionary*)info {
    
}

- (void)sendInviteUsers:(NSArray*)invitees toStream:(NSString*)streamID {
    NSString * participantCSV = [invitees componentsJoinedByString:@","];
    NSMutableString *strippedString = [NSMutableString
                                       stringWithCapacity:participantCSV.length];

    NSScanner *scanner = [NSScanner scannerWithString:participantCSV];
    NSCharacterSet *numbers = [NSCharacterSet
                               characterSetWithCharactersInString:@"0123456789,"];
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];

        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"api/invitePeople1.php?inviteesPhone=%@&inviterPhone=%@&streamID=%@", strippedString, mMe.phone, streamID]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskSendInvite]);
    
}

- (void)p_sentInvite:(NSDictionary*)info {
    
}

- (void)downloadParticipantsInStream:(NSString*)streamID {
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"stream/1.0/api/get_users_in_stream.php?stream_id=%@", streamID]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskDownloadParticipants]);
}

- (void)p_downloadedParticipants:(NSDictionary*)info {
    if (info && [[info objectForKey:@"status"] isEqualToString:@"ok"]) {
        TRPhotoStream * stream = [self getStreamWithID:[info objectForKey:@"stream_id"]];
        NSArray * participants = [info objectForKey:@"users"];
        for (NSDictionary * participantInfo in participants) {
            TRUser * user = [self getUserWithPhone:[participantInfo objectForKey:@"uploader_phone"]];
            if (user == nil) {
                user = [[TRUser alloc] initWithPhone:[participantInfo objectForKey:@"uploader_phone"]
                                           firstName:[participantInfo objectForKey:@"uploader_first"]
                                            lastName:[participantInfo objectForKey:@"uploader_last"]];
                [self addUser:user];
            }
            [user setCountOfPhotos:[[participantInfo objectForKey:@"uploader_picturecount"] intValue] inStream:stream];
            [stream addParticipant:user];
        }
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
            case kTRGraphNetworkTaskUserSignup:
                [self p_receivedSignupResponse:info];
                break;
            case kTRGraphNetworkTaskDownloadStreamInfo:
                [self p_downloadedStreamInfo:info];
                break;
            case kTRGraphNetworkTaskDownloadPhotoInfo:
                [self p_downloadedPhotoInfo:info];
                break;
            case kTRGraphNetworkTaskUploadPhoto:
                [self p_uploadedPhoto:info];
                break;
            case kTRGraphNetworkTaskCreateStream:
                [self p_createdStream:info];
                break;
            case kTRGraphNetworkTaskDownloadParticipants:
                [self p_downloadedParticipants:info];
                break;
            case kTRGraphNetworkTaskDownloadUserPhotos:
                [self p_downloadedUserPhotos:info];
                break;
            case kTRGraphNetworkTaskDownloadLikes:
                [self p_downloadedLikes:info];
                break;
            case kTRGraphNetworkTaskSendInvite:
                [self p_sentInvite:info];
                break;
            case kTRGraphNetworkTaskGetUserStatus:
                [self p_downloadedUserStatus:info];
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

- (void)connection:(TRConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    for (id<TRGraphDelegate> delegate in [mDelegates copy]) {
        if ([delegate respondsToSelector:@selector(uploadedBytes:ofExpected:)]) {
            [delegate uploadedBytes:totalBytesWritten ofExpected:totalBytesExpectedToWrite];
        }
    }

}

- (void) didReceiveMemoryWarning {
    for (TRPhoto * photo in [mPhotos allValues]) {
        [photo.image flushCache];
        photo.image = nil;
    }
}

@end
