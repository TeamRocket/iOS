//
//  TRStreamGridViewCell.h
//  Stream
//
//  Created by Peter Tsoi on 12/14/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TRImageView;
@class TRPhoto;

@interface TRStreamGridViewCell : UITableViewCell {
    IBOutlet TRImageView * mLeftFrame;
    IBOutlet TRImageView * mRightFrame;
}

@property (nonatomic) TRImageView * leftFrame;
@property (nonatomic) TRImageView * rightFrame;

@end
