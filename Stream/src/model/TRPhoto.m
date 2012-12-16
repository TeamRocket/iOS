//
//  TRPhoto.m
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRPhoto.h"

#import "TRImage.h"

@implementation TRPhoto

@synthesize uploader = mUploader;
@synthesize URL = mURL;
@synthesize image = mImage;
@synthesize numLikes = mNumLikes;

- (id) initWithURL:(NSURL*)url uploader:(TRUser*)uploader {
    self = [super init];
    if (self) {
        mUploader = uploader;
        mURL = url;

        mImage = [[TRImage alloc] initWithURL:mURL];
    }
    return self;
}

@end
