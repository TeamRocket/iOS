//
//  TRNetwork.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TRNetwork;
@class TRConnection;

@protocol TRConnectionDelegate

- (void)connection:(TRConnection *)connection finishedDownloadingData:(NSData *)data;
- (void)connection:(TRConnection *)connection failedWithError:(NSError *)error;

@end

@interface TRConnection : NSURLConnection {
    id<TRConnectionDelegate> mDelegate;
}

@property (nonatomic) id<TRConnectionDelegate> delegate;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate networkDelegate:(TRNetwork *)network startImmediately:(BOOL)startImmediately;
- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate;

@end

@interface TRNetwork : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    CFMutableDictionaryRef mActiveConnections;
}

- (TRConnection *)dataAtURL:(NSURL *)url delegate:(id<TRConnectionDelegate>) delegate;
- (TRConnection *)postToURL:(NSURL *)url arguments:(NSDictionary*)args data:(NSData*)data delegate:(id<TRConnectionDelegate>) delegate;

@end
