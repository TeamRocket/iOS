//
//  TRImage.h
//  Stream
//
//  Created by Peter Tsoi on 12/13/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRNetwork.h"

@class TRImage;

@interface TRImage : UIImage {
    NSURL * mURL;
    BOOL mLoaded;

    NSMutableDictionary * mSizedPhotos;
}

@property (nonatomic, readonly) BOOL loaded;
@property (nonatomic, readonly) NSURL * url;

- (id) initWithURL:(NSURL *)url;
- (id) initWithData:(NSData *)data fromURL:(NSURL*)url;
- (TRImage *)sizedTo:(CGSize)size;
+ (TRImage *) imageWithImage:(TRImage *)image scaledToSize:(CGSize)newSize;

@end

