//
//  TRStreamCell.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TRImage.h"
#import "TRImageView.h"

@interface TRStreamCell : UITableViewCell {
    IBOutlet TRImageView * mImageView;
    IBOutlet UILabel * mTitleLabel;
    IBOutlet UILabel * mParticipantsLabel;
    IBOutlet UILabel * mPhotosLabel;
}

@property (nonatomic) UIImageView * imageView;
@property (nonatomic) UILabel * titleLabel;
@property (nonatomic) UILabel * participantsLabel;
@property (nonatomic) UILabel * photosLabel;

- (void)setImage:(TRImage*)image;

@end
