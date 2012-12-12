//
//  TRTextFieldCell.h
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRTableViewCell.h"

@interface TRTextFieldCell : TRTableViewCell {
    IBOutlet UITextField * mTextField;
}

@property (strong, nonatomic) UITextField * textField;

@end
