//
//  TRImageView.m
//  Stream
//
//  Created by Peter Tsoi on 12/13/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TRImageView.h"

#import "TRAppDelegate.h"
#import "TRImage.h"
#import "TRPhoto.h"

@implementation TRImageView

@synthesize tapRecognizer = mTapRecognizer;
@synthesize TRPhoto = mPhoto;

- (id)initWithImage:(UIImage *)image {
    self = [self initWithFrame:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height)];
    if (self) {
        mPostDownloadResize = CGSizeZero;
        [self setBackgroundColor:[UIColor colorWithPatternImage:image]];
    }
    return self;
}

- (id)initWithTRImage:(TRImage *)image inFrame:(CGRect)frame{
    if (image.loaded) {
        self = [self initWithImage:(UIImage *)[image sizedTo:frame.size]];
        self.frame = frame;
    } else {
        self = [self initWithURL:image.url inFrame:frame];
    }

    if (self) {
        mPostDownloadResize = CGSizeZero;
    }
    return self;
}

- (id)initWithTRPhoto:(TRPhoto*)photo inFrame:(CGRect)frame {
    if (photo.image) {
        self = [self initWithTRImage:photo.image inFrame:frame];
    } else {
        self = [self initWithURL:photo.URL inFrame:frame];
    }
    if (self) {
        mPostDownloadResize = CGSizeZero;
        mPhoto = photo;
    }
    return self;
}

- (id)initWithTRPhoto:(TRPhoto *)photo fitInFrame:(CGRect)frame {
    self = [self initWithTRPhoto:photo inFrame:frame];
    if (self) {
        mPostDownloadResize = frame.size;
    }
    return self;
}

- (id)initWithURL:(NSURL *)url inFrame:(CGRect)frame {
    self = [self initWithFrame:frame];
    if (self) {
        mSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        mSpinner.center = self.center;
        [mSpinner startAnimating];
        [self addSubview:mSpinner];
        mConnection = [AppDelegate.network dataAtURL:url delegate:self];
    }
    return self;
}

- (void)setTRImage:(TRImage*)image {
    [self setPlaceholder];
    mPostDownloadResize = CGSizeZero;
    mSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    mSpinner.center = self.center;
    [mSpinner startAnimating];
    [self addSubview:mSpinner];
    if (mConnection)
        [mConnection cancel];
    mConnection = [AppDelegate.network dataAtURL:image.url delegate:self];
}

- (void)setTRPhoto:(TRPhoto*)photo {
    [self setImage:nil];
    mPostDownloadResize = CGSizeZero;
    mPhoto = photo;
    if ([photo.image loaded]) {
        [self setBackgroundColor:[UIColor colorWithPatternImage:[mPhoto.image sizedTo:self.frame.size]]];
    } else {
        if (!photo.image) {
            [self setPlaceholder];
            mSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            mSpinner.center = self.center;
            [mSpinner startAnimating];
            [self addSubview:mSpinner];
            if (mConnection)
                [mConnection cancel];
            mConnection = [AppDelegate.network dataAtURL:photo.URL delegate:self];
        } else 
            [self setTRImage:photo.image];
    }
}

- (void)setPictureInnerShadow:(BOOL)shadow {
    if (shadow) {
        CALayer *innerShadowLayer = [CALayer layer];
        innerShadowLayer.frame = CGRectMake(0.0, 0.0,
                                            self.layer.frame.size.width, self.layer.frame.size.height);
        innerShadowLayer.contents = (id)[UIImage imageNamed: @"inner_shadow.png"].CGImage;
        innerShadowLayer.contentsCenter = CGRectMake(10.0f/30.0f, 10.0f/30.0f, 10.0f/30.0f, 10.0f/30.0f);
        [self.layer insertSublayer:innerShadowLayer atIndex:0];
        [self.layer setShouldRasterize:YES];
    } else {
        if ([[self.layer sublayers] count] > 1)
            [[[self.layer sublayers] objectAtIndex:0] removeFromSuperlayer];
    }
}

- (void)setPlaceholder {
    if (CGSizeEqualToSize(self.frame.size, CGSizeMake(145.0f, 145.0f))) {
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"upload_placeholder.png"]]];
    } else {
        [self setBackgroundColor:[UIColor blackColor]];
    }
}

- (void)setTapRecognizer:(UITapGestureRecognizer *)tapRecognizer {
    [self addGestureRecognizer:tapRecognizer];
    mTapRecognizer = tapRecognizer;
}

#pragma mark - FCConnectionDelegate

- (void)connection:(TRConnection *)connection finishedDownloadingData:(NSData *)data {
    if (connection == mConnection) {
        mConnection = nil;
        [mSpinner stopAnimating];
        mSpinner = nil;
        mImage = [[TRImage alloc] initWithData:data fromURL:mImage.url];
        if (mPhoto != nil)
            mPhoto.image = mImage;
        if (!CGSizeEqualToSize(mPostDownloadResize, CGSizeZero)) {
            CGPoint oldCenter = self.center;
            CGSize photoSize = [mPhoto.image bestFitForSize:mPostDownloadResize];
            // Using mPostDownloadResize.width because the full photo view crops to width...
            // not technically correct, but it suits the purpose
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                    mPostDownloadResize.width, photoSize.height);
            self.center = oldCenter;
        }
        [self setBackgroundColor:[UIColor colorWithPatternImage:[mImage sizedTo:self.frame.size]]];
    }
}

- (void)connection:(TRConnection *)connection failedWithError:(NSError *)error {
    [mSpinner stopAnimating];
    mSpinner = nil;
    NSLog(@"Image load error: %@", error);
}

@end
