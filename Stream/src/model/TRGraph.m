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
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"api/signin.php?first=%@&password=%@", [first encodeString:NSASCIIStringEncoding], [password encodeString:NSASCIIStringEncoding]]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskUserLogin]);
}

- (void)signupWithPhone:(NSString*)phone first:(NSString*)first last:(NSString*)last password:(NSString*)password {
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"api/signup.php?first=%@&last=%@&phone=%@&password=%@",
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
    if (info) {
        TRUser * user = [self getUserWithPhone:[info objectForKey:@"phone"]];
        if (user == nil && ![[info objectForKey:@"value"] isEqualToString:@"false"] && ![[info objectForKey:@"value"] isEqualToString:@""]) {
            user = [[TRUser alloc] initWithPhone:[info objectForKey:@"phone"]
                                       firstName:[info objectForKey:@"first"]
                                        lastName:[info objectForKey:@"last"]];
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

- (TRUser*)getUserWithPhone:(NSString*)phone {
    return [mUsers objectForKey:phone];
}

#pragma mark Photo

- (void)sendLikePhoto:(NSString*)ID forPhone:(NSString*)phone{
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"api/likePicture.php?phone=%@&pictureID=%@", phone, ID]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskSendLikePhoto]);
}

- (void)sendUnlikePhoto:(NSString*)ID forPhone:(NSString*)phone{
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"api/unlikePicture.php?phone=%@&pictureID=%@", phone, ID]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskSendUnlikePhoto]);
}

- (void)downloadPhotoInfo:(NSString*)ID {
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"api/getPictureMetadata2.php?pictureID=%@", ID]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskDownloadPhotoInfo]);
}

- (void)p_downloadedPhotoInfo:(NSDictionary*)info {
    if ([info objectForKey:@"pictureID"]) {
        TRPhoto * photo = [self getPhotoWithID:[info objectForKey:@"pictureID"]];
        if (!photo) {
            photo = [[TRPhoto alloc] initWithID:[info objectForKey:@"pictureID"]
                                            URL:[NSURL URLWithString:[info objectForKey:@"picture_url"]]
                                       uploader:nil];
            [self addPhoto:photo];
        }
        if ([info objectForKey:@"uploaderPhone"]) {
            TRUser * user = [self getUserWithPhone:[info objectForKey:@"uploaderPhone"]];
            if (user == nil) {
                user = [[TRUser alloc] initWithPhone:[info objectForKey:@"uploaderPhone"]
                                           firstName:[info objectForKey:@"uploaderFirstName"]
                                            lastName:[info objectForKey:@"uploaderLastName"]];
                [self addUser:user];
            } else {
                user.firstName = [info objectForKey:@"uploaderFirstName"];
                user.lastName = [info objectForKey:@"uploaderLastName"];
            }
            photo.uploader = user;
        }
        photo.numLikes = [[info objectForKey:@"numberOfLikes"] intValue];
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
                               photo.uploader.phone, @"phoneNumber",
                               stream.ID, @"streamID",
                               nil];
        TRConnection * conn = [AppDelegate.network postToURL:[NSURL URLWithString:@"upload/upload_file.php"
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
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"api/getUserPhotos2.php?viewerPhone=%@&streamerPhone=%@&streamID=%@", mMe.phone, phone, streamID]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskDownloadUserPhotos]);
}

- (void)p_downloadedUserPhotos:(NSDictionary*)info {
    if (info != nil) {
        TRPhotoStream * stream = [self getStreamWithID:[info objectForKey:@"streamID"]];
        if (stream != nil) {
            TRUser * user = [self getUserWithPhone:[info objectForKey:@"phone"]];
            if (user == nil) {
                user = [[TRUser alloc] initWithPhone:[info objectForKey:@"phone"]
                                           firstName:nil lastName:nil];
                [self addUser:user];
            }
            NSArray * photos = [info objectForKey:@"pictures"];
            for (NSDictionary * photoInfo in photos) {
                TRPhoto * photo = [self getPhotoWithID:[photoInfo objectForKey:@"id"]];
                if (photo == nil) {
                    photo = [[TRPhoto alloc] initWithID:[photoInfo objectForKey:@"id"]
                                                    URL:[NSURL URLWithString:[photoInfo objectForKey:@"url"]]
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
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"api/getPeopleWhoLike2.php?pictureID=%@", ID]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskDownloadLikes]);
}

- (void)p_downloadedLikes:(NSDictionary*)info {
    if (info != nil) {
        TRPhoto * photo = [self getPhotoWithID:[info objectForKey:@"pictureID"]];
        NSArray * likers = [info objectForKey:@"likers"];
        if (photo != nil) {
            for (NSDictionary * likerInfo in likers) {
                TRUser * user = [self getUserWithPhone:[likerInfo objectForKey:@"phone"]];
                if (user == nil) {
                    user = [[TRUser alloc] initWithPhone:[likerInfo objectForKey:@"phone"]
                                               firstName:[likerInfo objectForKey:@"first"]
                                                lastName:[likerInfo objectForKey:@"last"]];
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
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"api/populateStreamNewsfeed2.php?phone=%@", phone]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskDownloadUserPhotoStreams]);
}

- (void)p_downloadedUserPhotoStreams:(NSDictionary*)data {
    for (NSString * ID in data) {
        NSDictionary * streamData = [data objectForKey:ID];
        TRPhotoStream * newStream = [self getStreamWithID:ID];
        if (newStream == nil) {
            newStream = [[TRPhotoStream alloc] initWithID:ID name:[streamData objectForKey:@"streamName"]
                                             participants:[[streamData objectForKey:@"numberOfParticipants"] intValue]
                                                   photos:[[streamData objectForKey:@"numberOfPictures"] intValue]];
            [self addStream:newStream];
        } else {
            newStream.name = [streamData objectForKey:@"streamName"];
            newStream.numParticipants = [[streamData objectForKey:@"numberOfParticipants"] intValue];
            newStream.numPhotos = [[streamData objectForKey:@"numberOfPictures"] intValue];
        }
        NSDictionary * latestInfo = [streamData objectForKey:@"latestPicture"];
        if (![[NSNull null] isEqual:latestInfo]) {
            TRPhoto * latestPhoto = [self getPhotoWithID:[latestInfo objectForKey:@"id"]];
            if (latestPhoto == nil) {
                latestPhoto = [[TRPhoto alloc] initWithID:[latestInfo objectForKey:@"id"]
                                                      URL:[NSURL URLWithString:[latestInfo objectForKey:@"url"]]
                                                 uploader:nil];
                [self addPhoto:latestPhoto];
            }
            [newStream addPhotoAsLatest:latestPhoto];
        }
        [mMe addStream:newStream];
    }
}

- (void)downloadStreamInfo:(NSString*)stream forPhone:(NSString*)phone {
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"api/populateStreamProfile2.php?phone=%@&streamID=%@", phone, stream]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskDownloadStreamInfo]);
}

- (void)p_downloadedStreamInfo:(NSDictionary*)info {
    TRPhotoStream * stream = [self getStreamWithID:[info objectForKey:@"streamID"]];
    if (stream != nil) {
        NSArray * pictures = [info objectForKey:@"pictures"];
        for (NSDictionary * photoInfo in pictures) {
            if (photoInfo) {
                TRPhoto * newPhoto = [self getPhotoWithID:[photoInfo objectForKey:@"pictureID"]];
                if (newPhoto == nil) {
                    newPhoto = [[TRPhoto alloc] initWithID:[photoInfo objectForKey:@"pictureID"]
                                                       URL:[NSURL URLWithString:[photoInfo objectForKey:@"url"]]
                                                  uploader:nil];
                    [self addPhoto:newPhoto];
                }
                [stream addPhoto:newPhoto];
                stream.numPhotos = [stream.photos count];
            }
        }
        if ([pictures count] > 0) {
            [stream addPhotoAsLatest: [self getPhotoWithID:[[pictures objectAtIndex:0] objectForKey:@"pictureID"]]];
        }
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
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"api/createStream.php?phone=%@&streamName=%@&invitees=%@", phone, [streamName encodeString:NSASCIIStringEncoding], strippedString]
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
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"api/invitePeople.php?phone=%@&streamID=%@", strippedString, streamID]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskSendInvite]);
    
}

- (void)p_sentInvite:(NSDictionary*)info {
    
}

- (void)downloadParticipantsInStream:(NSString*)streamID {
    TRConnection * conn = [AppDelegate.network dataAtURL:[NSURL URLWithString:[NSString stringWithFormat:@"api/getPeopleInStream1.php?streamID=%@", streamID]
                                                                relativeToURL:[NSURL URLWithString:@"http://75.101.134.112"]] delegate:self];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSString stringWithFormat:@"%i",kTRGraphNetworkTaskDownloadParticipants]);
}

- (void)p_downloadedParticipants:(NSDictionary*)info {
    if (info != nil) {
        TRPhotoStream * stream = [self getStreamWithID:[info objectForKey:@"streamID"]];
        NSArray * participants = [info objectForKey:@"participants"];
        for (NSDictionary * participantInfo in participants) {
            TRUser * user = [self getUserWithPhone:[participantInfo objectForKey:@"phone"]];
            if (user == nil) {
                user = [[TRUser alloc] initWithPhone:[participantInfo objectForKey:@"phone"]
                                           firstName:[participantInfo objectForKey:@"first"]
                                            lastName:[participantInfo objectForKey:@"last"]];
                [self addUser:user];
            }
            [user setCountOfPhotos:[[participantInfo objectForKey:@"numberOfPhotos"] intValue] inStream:stream];
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

- (void) didReceiveMemoryWarning {
    for (TRPhoto * photo in [mPhotos allValues]) {
        [photo.image flushCache];
        photo.image = nil;
    }
}

@end
