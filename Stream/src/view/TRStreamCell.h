//
//  TRStreamCell.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TRStreamCell : UITableViewCell {
    IBOutlet UIImageView * mImageView;
    IBOutlet UILabel * mTitleLabel;
    IBOutlet UILabel * mParticipantsLabel;
    IBOutlet UILabel * mPhotosLabel;
}

@property (nonatomic) UIImageView * imageView;
@property (nonatomic) UILabel * titleLabel;
@property (nonatomic) UILabel * participantsLabel;
@property (nonatomic) UILabel * photosLabel;

@end
