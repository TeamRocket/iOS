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

@interface TRGraph : NSObject <TRConnectionDelegate> {
    NSMutableArray * mDelegates;
    CFMutableDictionaryRef mActiveConnections;

    NSMutableDictionary * mStreams;
    NSMutableDictionary * mPhotos;
}

- (id)initWithDelegate:(id<TRGraphDelegate>)delegate;
- (void)registerForDelegateCallback:(id<TRGraphDelegate>)delegate;
- (void)unregisterForDelegateCallback:(id<TRGraphDelegate>)delegate;

- (void)downloadUserPhotoStreams:(NSString*)phone;

@end
