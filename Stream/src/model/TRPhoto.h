//
//  TRPhoto.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TRUser;
@class TRImage;

@interface TRPhoto : NSObject {
    TRUser * mUploader;
    NSURL * mURL;
    TRImage * mImage;
}

@property (nonatomic) TRUser * uploader;
@property (nonatomic, readonly) NSURL * URL;
@property (nonatomic) TRImage * image;

- (id) initWithURL:(NSURL*)url uploader:(TRUser*)uploader;

@end
