//
//  TRParticipantCell.h
//  Stream
//
//  Created by Peter Tsoi on 12/23/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TRUser;

@interface TRParticipantCell : UITableViewCell {
    TRUser * mUser;
    IBOutlet UILabel * mParticipantNameLabel;
    IBOutlet UILabel * mPhotoCountLabel;
}

@property (nonatomic) TRUser * user;

- (void)setNumPhotos:(int)photos;

@end
