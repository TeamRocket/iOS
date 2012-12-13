//
//  TRImageView.m
//  Stream
//
//  Created by Peter Tsoi on 12/13/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRImageView.h"

#import "TRAppDelegate.h"

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
        self = [self initWithImage:(UIImage *)[TRImage imageWithImage:image scaledToSize:frame.size]];
        self.frame = frame;
    } else {
        self = [self initWithURL:image.url inFrame:frame];
    }

    if (self) {
        mImage = image;
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

#pragma mark - FCConnectionDelegate

- (void)connection:(TRConnection *)connection finishedDownloadingData:(NSData *)data {
    [mSpinner stopAnimating];
    TRImage * image = [[TRImage alloc] initWithData:data];
    mImage = [TRImage imageWithImage:image scaledToSize:self.frame.size];
    [self setBackgroundColor:[UIColor colorWithPatternImage:mImage]];
}

- (void)connection:(TRConnection *)connection failedWithError:(NSError *)error {
    [mSpinner stopAnimating];
    NSLog(@"Image load error: %@", error);
}

@end
