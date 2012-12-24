//
//  TRTableViewCell.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TRTableViewCellCapTypeNone,
    TRTableViewCellCapTypeTop,
    TRTableViewCellCapTypeTopBot,
    TRTableViewCellCapTypeBot,
} TRTableViewCellCapType;

@interface TRTableViewCell : UITableViewCell

- (void) setCapType:(TRTableViewCellCapType)type;

@end
