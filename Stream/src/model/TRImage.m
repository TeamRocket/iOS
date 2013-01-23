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

- (CGSize)bestFitForSize:(CGSize)newSize {
    float oldRatio = self.size.width/self.size.height;
    float newRatio = newSize.width/newSize.height;
    if (oldRatio > newRatio) {
        return CGSizeMake(newSize.width, newSize.width/oldRatio);
    } else {
        return CGSizeMake(newSize.height*oldRatio, newSize.height);
    }
}

+ (TRImage *) orientImage:(TRImage*)initImage {
    CGImageRef imgRef = initImage.CGImage;

    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);

    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = initImage.imageOrientation;
    switch(orient) {

        case UIImageOrientationUp: //EXIF = 1
            return initImage;
            break;

        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;

        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;

        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;

        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;

        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;

        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;

        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];

    }
    // Create the bitmap context
    CGContextRef    context = NULL;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;

    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (bounds.size.width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * bounds.size.height);
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        return nil;
    }

    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    CGColorSpaceRef colorspace = CGImageGetColorSpace(imgRef);
    context = CGBitmapContextCreate (bitmapData,bounds.size.width,bounds.size.height,8,bitmapBytesPerRow,
                                     colorspace,kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorspace);

    if (context == NULL)
        // error creating context
        return nil;

    CGContextScaleCTM(context, -1.0, -1.0);
    CGContextTranslateCTM(context, -height, -width);

    CGContextConcatCTM(context, transform);

    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(context, CGRectMake(0,0,width, height), imgRef);
    
    CGImageRef imgRef2 = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    free(bitmapData);
    UIImage * image = [UIImage imageWithCGImage:imgRef2 scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(imgRef2);
    return (TRImage*)image;
}


@end
