//
//  TRCommentsViewController.m
//  Stream
//
//  Created by Peter Tsoi on 1/23/13.
//  Copyright (c) 2013 TeamRocket. All rights reserved.
//

#import "TRCommentsViewController.h"

#import "TRAppDelegate.h"
#import "TRGraph.h"
#import "TRPhoto.h"
#import "TRUser.h"

#import "TRCommentCell.h"

@interface TRCommentsViewController ()

@end

@implementation TRCommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    mShouldFocus = NO;
    [mCommentsTable registerNib:[UINib nibWithNibName:@"TRCommentCell" bundle:nil] forCellReuseIdentifier:@"TRCommentCell"];
    [mCommentsTable setContentInset:UIEdgeInsetsMake(30.0f, 0.0f, 40.0f, 0.0f)];
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

- (void)viewDidAppear:(BOOL)animated {
    if (mShouldFocus) {
        [mCommentBox becomeFirstResponder];
    }
    mShouldFocus = NO;
    [TestFlight passCheckpoint:@"Viewed Comments"];
    [[Mixpanel sharedInstance] track:@"View Comments"];
}

-(void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self keyboardWillBeHidden:nil];
}

- (IBAction)sendButtonPressed:(id)sender {
    NSDictionary * newComment = [NSDictionary dictionaryWithObjectsAndKeys:
                                 mCommentBox.text, @"comment",
                                 AppDelegate.graph.me, @"commenter",
                                 [NSDate date], @"time",
                                 nil];
    [AppDelegate.graph sendNewComment:[newComment objectForKey:@"comment"] forPhoto:mPhoto.ID];
    [mPhoto addComment:newComment];
    [mCommentBox setText:@""];
    [self textViewDidChange:mCommentBox];
    [mCommentBox resignFirstResponder];
    [mCommentsTable reloadData];
    [mCommentsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[mPhoto.comments count]-1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [TestFlight passCheckpoint:@"Commented on Photo"];
    [[Mixpanel sharedInstance] track:@"Comment on Photo"];
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

- (void)setPhoto:(TRPhoto*)photo {
    mPhoto = photo;
    [mCommentsTable reloadData];
}

- (void)focus {
    mShouldFocus = YES;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mPhoto.comments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * comment = [[mPhoto.comments objectAtIndex:indexPath.row] objectForKey:@"comment"];
    CGSize commentSize = [comment sizeWithFont:[UIFont fontWithName:@"MuseoSans-100" size:15.0]
                             constrainedToSize:CGSizeMake(298, 300)
                                 lineBreakMode:NSLineBreakByWordWrapping];
    return commentSize.height + 40.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TRCommentCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TRCommentCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"TRCommentCell" owner:self options:nil][0];
    }
    NSDictionary * comment = [mPhoto.comments objectAtIndex:indexPath.row];
    TRUser * commenter = [comment objectForKey:@"commenter"];
    NSDate * time = [comment objectForKey:@"time"];
    NSTimeInterval timeSince = [[NSDate date] timeIntervalSinceDate:time];
    [cell setComment:[comment objectForKey:@"comment"]];
    [cell setCommenter:[NSString stringWithFormat:@"%@ %@", commenter.firstName, commenter.lastName]];
    if (timeSince < 60) {
        [cell setTime:@"now"];
    } else if (timeSince < 3600) {
        [cell setTime:[NSString stringWithFormat:@"%i m", (int)timeSince/60]];
    } else if (timeSince < 86400) {
        [cell setTime:[NSString stringWithFormat:@"%i h", (int)timeSince/3600]];
    } else if (timeSince < 604800) {
        [cell setTime:[NSString stringWithFormat:@"%i d", (int)timeSince/86400]];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        [cell setTime:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:time]]];
    }
    return cell;
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

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(mCommentsTable.contentInset.top, mCommentsTable.contentInset.left,
                                                  mCommentsTable.contentInset.bottom + mKBSize.height, mCommentsTable.contentInset.right);
    mCommentsTable.contentInset = contentInsets;
    mCommentsTable.scrollIndicatorInsets = contentInsets;
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
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(mCommentsTable.contentInset.top, mCommentsTable.contentInset.left,
                                                  mCommentsTable.contentInset.bottom - mKBSize.height, mCommentsTable.contentInset.right);

    mCommentsTable.contentInset = contentInsets;
    mCommentsTable.scrollIndicatorInsets = contentInsets;
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
        if ([textView.text length] > 0 && [textView.text characterAtIndex:[textView.text length] - 1] == '\n') {
            textView.text = [textView.text substringToIndex:[textView.text length]-1];
            [self textViewDidChange:textView];
            [textView resignFirstResponder];
        }
    }
}

- (void)graphFinishedUpdating {
    [self setPhoto:mPhoto];
}

@end
