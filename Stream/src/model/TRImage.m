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
        mSizedPhotos = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id) initWithData:(NSData *)data fromURL:(NSURL*)url {
    self = [super initWithData:data];
    if (self) {
        mURL = url;
        mSizedPhotos = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL) loaded {
    return self.CGImage || self.CIImage || [[mSizedPhotos allKeys] count] > 0;
}

- (TRImage *)sizedTo:(CGSize)size {
    NSString * sizeKey = [NSString stringWithFormat:@"%fx%f", size.width, size.height];
    TRImage * sizedPhoto = [mSizedPhotos objectForKey:sizeKey];
    if (sizedPhoto == nil) {
        sizedPhoto = [TRImage imageWithImage:self fitToSize:size];
        [mSizedPhotos setValue:sizedPhoto forKey:sizeKey];
    }
    return sizedPhoto;
}

- (void)flushCache {
    [mSizedPhotos removeAllObjects];
}

+ (TRImage *) imageWithImage:(TRImage *)image croppedToRect:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    TRImage * rv = (TRImage *)[TRImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return rv;
}

+ (TRImage *) imageWithImage:(TRImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    TRImage *newImage = (TRImage *)UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (TRImage *) imageWithImage:(TRImage *)image fitToSize:(CGSize)newSize {
    float oldRatio = image.size.width/image.size.height;
    float newRatio = newSize.width/newSize.height;
    CGRect largeCropRect;
    if (oldRatio > newRatio) {
        // Old image was too wide
        largeCropRect = CGRectMake((image.size.width - (image.size.height * newRatio))/2, 0.0,
                                   image.size.height * newRatio, image.size.height);
    } else if (oldRatio == newRatio) {
        largeCropRect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    } else if (oldRatio < newRatio) {
        // Old image was too tall
        largeCropRect = CGRectMake(0.0, (image.size.height-(image.size.width/newRatio))/2,
                                   image.size.width, image.size.width/newRatio);
    }
    return [TRImage imageWithImage:[TRImage imageWithImage:image croppedToRect:largeCropRect] scaledToSize:newSize];
}


@end
