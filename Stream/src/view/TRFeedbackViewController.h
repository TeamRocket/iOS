//
//  TRFeedbackViewController.h
//  Stream
//
//  Created by Peter Tsoi on 2/1/13.
//  Copyright (c) 2013 TeamRocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TRFeedbackViewController : UIViewController {
    IBOutlet UIBarButtonItem * mCancelBtn;
    IBOutlet UIBarButtonItem * mSendBtn;
    IBOutlet UITextView * mFeedbackBox;

    CGSize mKBSize;
}

@end
