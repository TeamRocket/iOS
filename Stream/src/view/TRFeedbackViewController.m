//
//  TRFeedbackViewController.m
//  Stream
//
//  Created by Peter Tsoi on 2/1/13.
//  Copyright (c) 2013 TeamRocket. All rights reserved.
//

#import "TRFeedbackViewController.h"

@interface TRFeedbackViewController ()

@end

@implementation TRFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [mCancelBtn setBackgroundImage:[UIImage imageNamed:@"navbarback.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [mCancelBtn setBackgroundImage:[UIImage imageNamed:@"navbarback_highlighted.png"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [mCancelBtn setTitlePositionAdjustment:UIOffsetMake(5.0f, 0.0f) forBarMetrics:UIBarMetricsDefault];
    [mCancelBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"MuseoSans-500" size:11.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
    [mSendBtn setBackgroundImage:[UIImage imageNamed:@"navbaritem_orange.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [mSendBtn setBackgroundImage:[UIImage imageNamed:@"navbaritem_orange_highlighted.png"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [mSendBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"MuseoSans-500" size:11.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
    [mFeedbackBox setFont:[UIFont fontWithName:@"MuseoSans-300" size:15.0f]];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendButtonPressed:(id)sender {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    mKBSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    if ([mFeedbackBox.text isEqualToString:@"What do you think about stream?"]) {
        mFeedbackBox.text = @"";
        mFeedbackBox.textColor = [UIColor blackColor];
    }

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(mFeedbackBox.contentInset.top, mFeedbackBox.contentInset.left,
                                                  mFeedbackBox.contentInset.bottom + mKBSize.height, mFeedbackBox.contentInset.right);
    mFeedbackBox.contentInset = contentInsets;
    mFeedbackBox.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    if ([mFeedbackBox.text isEqualToString:@""]) {
        mFeedbackBox.text = @"What do you think about stream?";
        mFeedbackBox.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    }
    [UIView commitAnimations];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(mFeedbackBox.contentInset.top, mFeedbackBox.contentInset.left,
                                                  mFeedbackBox.contentInset.bottom - mKBSize.height, mFeedbackBox.contentInset.right);

    mFeedbackBox.contentInset = contentInsets;
    mFeedbackBox.scrollIndicatorInsets = contentInsets;
}

@end
