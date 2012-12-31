//
//  TRNetwork.m
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRNetwork.h"

#import "TRAppDelegate.h"

@implementation TRConnection

@synthesize delegate = mDelegate;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate networkDelegate:(TRNetwork *)network startImmediately:(BOOL)startImmediately {
    self = [super initWithRequest:request delegate:AppDelegate.network startImmediately:startImmediately];
    if (self) {
        mDelegate = delegate;
    }
    return self;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate {
    self = [self initWithRequest:request delegate:delegate networkDelegate:AppDelegate.network startImmediately:YES];
    if (self) {

    }
    return self;
}

@end

@implementation TRNetwork

- (id)init{
    self = [super init];
    if (self) {
        mActiveConnections = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                       0,
                                                       &kCFTypeDictionaryKeyCallBacks,
                                                       &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

- (TRConnection *)postToURL:(NSURL *)url arguments:(NSDictionary*)args data:(NSData*)data delegate:(id<TRConnectionDelegate>) delegate{
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPMethod:@"POST"];

    NSString *boundary = @"------TeamRocketBoundaryJESSIEJAMESMEOWTH";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];

    for (NSString * key in args) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"%@\r\n",[args objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    if (data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];

    TRConnection * conn = [[TRConnection alloc] initWithRequest:request delegate:delegate networkDelegate:self startImmediately:NO];
    [conn scheduleInRunLoop:[NSRunLoop currentRunLoop]
                    forMode:NSRunLoopCommonModes];
    [conn start];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSMutableData data]);
    return conn;
}

- (TRConnection *)dataAtURL:(NSURL *)url delegate:(id<TRConnectionDelegate>) delegate{
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    TRConnection * conn = [[TRConnection alloc] initWithRequest:request delegate:delegate networkDelegate:self startImmediately:NO];
    [conn scheduleInRunLoop:[NSRunLoop currentRunLoop]
                    forMode:NSRunLoopCommonModes];
    [conn start];
    CFDictionaryAddValue(mActiveConnections,
                         (__bridge const void *)conn,
                         (__bridge const void *)[NSMutableData data]);
    return conn;
}

#pragma mark - NSURLConnection

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (CFDictionaryContainsKey(mActiveConnections, (__bridge const void *)connection)) {
        NSMutableData * connectionData = CFDictionaryGetValue(mActiveConnections, (__bridge const void *)connection);
        [connectionData appendData:data];
    } else
        NSLog(@"Response was never created...");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    TRConnection * conn = (TRConnection*)connection;
    if (CFDictionaryContainsKey(mActiveConnections, (__bridge const void *)conn)) {
        NSMutableData * connectionData = CFDictionaryGetValue(mActiveConnections, (__bridge const void *)conn);
        [conn.delegate connection:conn finishedDownloadingData:connectionData];
        CFDictionaryRemoveValue(mActiveConnections, (__bridge const void *)conn);
    } else
        NSLog(@"Response was never created...");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    TRConnection * conn = (TRConnection*)connection;
    if (CFDictionaryContainsKey(mActiveConnections, (__bridge const void *)conn)) {
        [conn.delegate connection:conn failedWithError:error];
        CFDictionaryRemoveValue(mActiveConnections, (__bridge const void *)conn);
    } else
        NSLog(@"Response was never created...");
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    TRConnection * conn = (TRConnection*)connection;
    if (CFDictionaryContainsKey(mActiveConnections, (__bridge const void *)conn)) {
        [conn.delegate connection:conn didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    } else
        NSLog(@"Response was never created...");
}

@end
