//
//  TRStreamCell.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TRImageView.h"

@class TRImage;
@class TRPhoto;

@interface TRStreamCell : UITableViewCell {
    IBOutlet TRImageView * mImageView;
    IBOutlet UILabel * mTitleLabel;
    IBOutlet UILabel * mParticipantsLabel;
    IBOutlet UILabel * mPhotosLabel;
    IBOutlet UIImageView * mBackground;

    TRPhoto * mPhoto;
}

@property (nonatomic) UIImageView * imageView;
@property (nonatomic) UILabel * titleLabel;
@property (nonatomic) UILabel * participantsLabel;
@property (nonatomic) UILabel * photosLabel;

- (void)setImage:(TRImage*)image;
- (void)setPhoto:(TRPhoto*)photo;
- (void)setBlankPhoto;

@end
