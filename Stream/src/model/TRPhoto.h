//
//  TRPhoto.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TRUser;

@interface TRPhoto : NSObject {
    TRUser * mUploader;
    NSURL * mURL;
}

@property (nonatomic) TRUser * uploader;
@property (nonatomic, readonly) NSURL * URL;

- (id) initWithURL:(NSURL*)url uploader:(TRUser*)uploader;

@end
