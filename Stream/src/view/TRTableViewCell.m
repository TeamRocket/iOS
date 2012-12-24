//
//  TRTableViewCell.m
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRTableViewCell.h"

@implementation TRTableViewCell

- (void) setCapType:(TRTableViewCellCapType)type {
    UIImage * bgImage;
    switch (type) {
        case TRTableViewCellCapTypeTopBot:
            bgImage = [[UIImage imageNamed:@"tableviewgrouped_cap.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0, 3.0, 5.0, 4.0)];
            break;
        case TRTableViewCellCapTypeBot:
            bgImage = [[UIImage imageNamed:@"tableviewgrouped_bot.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 3.0, 3.0, 4.0)];
            break;
        case TRTableViewCellCapTypeTop:
            bgImage = [[UIImage imageNamed:@"tableviewgrouped_top.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3.0, 3.0, 1.0, 4.0)];
            break;
        case TRTableViewCellCapTypeNone:
        default:
            bgImage = [[UIImage imageNamed:@"tableviewgrouped_mid.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 3.0, 1.0, 4.0)];
            break;
    }
    [self setBackgroundView:[[UIImageView alloc] initWithImage:bgImage]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
}

@end
