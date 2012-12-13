//
//  TRImage.m
//  Stream
//
//  Created by Peter Tsoi on 12/13/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRImage.h"

@implementation TRImage

@synthesize loaded = mLoaded;
@synthesize url = mURL;

- (id) initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        mURL = url;
    }
    return self;
}

- (BOOL) loaded {
    return self.CGImage || self.CIImage;
}

+ (TRImage *) imageWithImage:(TRImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    TRImage *newImage = (TRImage *)UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
