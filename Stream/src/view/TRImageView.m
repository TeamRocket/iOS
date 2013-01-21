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
        mPhoto = photo;
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
    [self setBackgroundColor:[UIColor whiteColor]];
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
    mPhoto = photo;
    if ([photo.image loaded]) {
        [self setBackgroundColor:[UIColor colorWithPatternImage:[mPhoto.image sizedTo:self.frame.size]]];
    } else {
        if (!photo.image) {
            [self setBackgroundColor:[UIColor whiteColor]];
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

- (void)setPictureFrame:(BOOL)frame {
    [self setPictureBorder:frame];
    [self setPictureShadow:frame];
    [self.layer setShouldRasterize:YES];
}

- (void)setPictureBorder:(BOOL)border {
    if (border) {
        [self.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.layer setBorderWidth:5.0f];
    } else {
        [self.layer setBorderWidth:0.0f];
    }
}

- (void)setPictureShadow:(BOOL)shadow {
    if (shadow) {
        [self.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.layer setShadowOpacity:0.5];
        [self.layer setShadowRadius:2.0];
        [self.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    } else {
        [self.layer setShadowOpacity:0.0f];
        [self.layer setShadowRadius:0.0f];
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
        [self setBackgroundColor:[UIColor colorWithPatternImage:[mImage sizedTo:self.frame.size]]];
    }
}

- (void)connection:(TRConnection *)connection failedWithError:(NSError *)error {
    [mSpinner stopAnimating];
    mSpinner = nil;
    NSLog(@"Image load error: %@", error);
}

@end
