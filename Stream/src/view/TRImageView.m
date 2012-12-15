//
//  TRImageView.m
//  Stream
//
//  Created by Peter Tsoi on 12/13/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRImageView.h"

#import "TRAppDelegate.h"
#import "TRImage.h"
#import "TRPhoto.h"

@implementation TRImageView

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
        mImage = image;
    }
    return self;
}

- (id)initWithTRPhoto:(TRPhoto*)photo inFrame:(CGRect)frame {
    self = [self initWithTRImage:photo.image inFrame:frame];
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
        [AppDelegate.network dataAtURL:url delegate:self];
    }
    return self;
}

- (void)setTRImage:(TRImage*)image {
    [self setBackgroundColor:[UIColor whiteColor]];
    mSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    mSpinner.center = self.center;
    [mSpinner startAnimating];
    [self addSubview:mSpinner];
    [AppDelegate.network dataAtURL:image.url delegate:self];
}

- (void)setTRPhoto:(TRPhoto*)photo {
    mPhoto = photo;
    mImage = photo.image;
    if ([photo.image loaded]) {
        [self setBackgroundColor:[UIColor colorWithPatternImage:[mPhoto.image sizedTo:self.frame.size]]];
    } else {
        [self setTRImage:photo.image];
    }
}

#pragma mark - FCConnectionDelegate

- (void)connection:(TRConnection *)connection finishedDownloadingData:(NSData *)data {
    [mSpinner stopAnimating];
    mImage = [[TRImage alloc] initWithData:data fromURL:mImage.url];
    if (mPhoto != nil)
        mPhoto.image = mImage;
    [self setBackgroundColor:[UIColor colorWithPatternImage:[mImage sizedTo:self.frame.size]]];
}

- (void)connection:(TRConnection *)connection failedWithError:(NSError *)error {
    [mSpinner stopAnimating];
    NSLog(@"Image load error: %@", error);
}

@end
