//
//  TRCommentsViewController.m
//  Stream
//
//  Created by Peter Tsoi on 1/23/13.
//  Copyright (c) 2013 TeamRocket. All rights reserved.
//

#import "TRCommentsViewController.h"

@interface TRCommentsViewController ()

@end

@implementation TRCommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [mSendButton.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:15.0]];
    [mBackButton.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:15.0]];
    [mSendButton setBackgroundImage:[[UIImage imageNamed:@"outline_button_bg.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)]
                           forState:UIControlStateNormal];
    [mTitleLabel setFont:[UIFont fontWithName:@"MuseoSans-300" size:22.0]];
    [mCommentBox setFont:[UIFont fontWithName:@"MuseoSans-300" size:15.0]];
    [mCommentBox setContentInset:UIEdgeInsetsMake(3.0f, 0.0f, 0.0f, 0.0f)];
    mLastCommentBoxHeight = mCommentBox.contentSize.height;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

-(void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self keyboardWillBeHidden:nil];
}

- (IBAction)sendButtonPressed:(id)sender {
    NSLog(@"Sent");
}

- (IBAction)backButtonPressed:(id)sender {
    [UIView beginAnimations:@"FadeOutCommentView" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeFromView)];
    [self.view setAlpha:0.0f];
    [UIView commitAnimations];
}

- (void)removeFromView {
    [self.view removeFromSuperview];
    [self.view setAlpha:1.0f];
}

- (void)setSendEnabled:(BOOL)enabled {
    mSendButton.enabled = enabled;
    if (enabled) {
        [mSendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [mSendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    mKBSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    mKBAnimationCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    mKBAnimationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];

    if ([mCommentBox.text isEqualToString:@"Write a comment..."]) {
        mCommentBox.text = @"";
        [self textViewDidChange:mCommentBox];
    }

    [UIView beginAnimations:@"AnimateKeyboardUp" context:nil];
    [UIView setAnimationCurve:mKBAnimationCurve];
    [UIView setAnimationDuration:mKBAnimationDuration];
    mBottomGradient.center = CGPointMake(mBottomGradient.center.x, mBottomGradient.center.y - mKBSize.height);
    mSendButton.center = CGPointMake(mSendButton.center.x, mSendButton.center.y - mKBSize.height);
    mCommentBox.center = CGPointMake(mCommentBox.center.x, mCommentBox.center.y - mKBSize.height);
    mBlackBack.center = CGPointMake(mBlackBack.center.x, mBlackBack.center.y - mKBSize.height);
    [UIView commitAnimations];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    [UIView beginAnimations:@"AnimateKeyboardDown" context:nil];
    [UIView setAnimationCurve:mKBAnimationCurve];
    [UIView setAnimationDuration:mKBAnimationDuration];
    if ([mCommentBox.text isEqualToString:@""]) {
        mCommentBox.text = @"Write a comment...";
        [self setSendEnabled:NO];
    }
    mBottomGradient.center = CGPointMake(mBottomGradient.center.x, mBottomGradient.center.y + mKBSize.height);
    mSendButton.center = CGPointMake(mSendButton.center.x, mSendButton.center.y + mKBSize.height);
    mCommentBox.center = CGPointMake(mCommentBox.center.x, mCommentBox.center.y + mKBSize.height);
    mBlackBack.center = CGPointMake(mBlackBack.center.x, mBlackBack.center.y + mKBSize.height);
    [UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if ([mCommentBox isFirstResponder]) {
        if (CGRectContainsPoint(mCommentBox.frame, [[touches anyObject] locationInView:mCommentBox])) {
            NSLog(@"Contains point");
        } else {
            [mCommentBox resignFirstResponder];
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView == mCommentBox) {
        if ([textView.text length] == 0) {
            [self setSendEnabled:NO];
        } else {
            [self setSendEnabled:YES];
        }
        if (textView.contentSize.height != mLastCommentBoxHeight) {
            if (mCommentBox.frame.size.height < 100.0f || textView.contentSize.height < mLastCommentBoxHeight) {
                float delta = mLastCommentBoxHeight - textView.contentSize.height;
                [UIView beginAnimations:@"GrowTextArea" context:nil];
                [UIView setAnimationCurve:mKBAnimationCurve];
                [UIView setAnimationDuration:mKBAnimationDuration];
                mBottomGradient.center = CGPointMake(mBottomGradient.center.x, mBottomGradient.center.y + delta);
                [mCommentBox setFrame:CGRectMake(mCommentBox.frame.origin.x, mCommentBox.frame.origin.y + delta,
                                                 mCommentBox.frame.size.width, mCommentBox.frame.size.height - delta)];
                [mBlackBack setFrame:CGRectMake(mCommentBox.frame.origin.x, mCommentBox.frame.origin.y,
                                                mBlackBack.frame.size.width, mCommentBox.frame.size.height)];
                [UIView commitAnimations];
                mLastCommentBoxHeight = textView.contentSize.height;
            }
        }
    }
}

@end
