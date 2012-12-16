//
//  TRPhotoViewController.m
//  Stream
//
//  Created by Peter Tsoi on 12/15/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TRPhotoViewController.h"

#import "TRAppDelegate.h"

#import "TRImageView.h"
#import "TRPhoto.h"
#import "TRUser.h"

#define IMAGE_SIZE 300.0f

@interface TRPhotoViewController ()

@end

@implementation TRPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)setPhotoView:(TRImageView*)photoView {
    mPhoto = photoView.TRPhoto;
    [AppDelegate.graph registerForDelegateCallback:self];
    [AppDelegate.graph downloadPhotoInfo:[mPhoto.URL absoluteString]];
    mImageView = photoView;
    [self.view addSubview:photoView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [mUploaderLabel setFont:[UIFont fontWithName:@"MuseoSans-300" size:22.0]];
    [mLikeButton.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:20.0]];
    [mLikeCountLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:20.0]];

    [UIView beginAnimations:@"PhotoScaleFull" context:nil];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(loadFullImage)];
    mImageView.center = self.view.center;
    [mImageView.layer setBorderWidth:mImageView.layer.borderWidth / (IMAGE_SIZE/mImageView.frame.size.width)];
    [mImageView setTransform:CGAffineTransformMakeScale(IMAGE_SIZE/mImageView.frame.size.width,
                                                        IMAGE_SIZE/mImageView.frame.size.height)];
    [UIView commitAnimations];
}

- (void)viewDidDisappear:(BOOL)animated {
    mUploaderLabel = nil;
    mPhoto = nil;
    mImageView = nil;
    mCloseButton = nil;
    [AppDelegate.graph unregisterForDelegateCallback:self];
}

- (void)loadFullImage {
    [mImageView setTransform:CGAffineTransformMakeScale(1.0f,
                                                        1.0f)];
    [mImageView setFrame:CGRectMake(0.0, 0.0, IMAGE_SIZE, IMAGE_SIZE)];
    mImageView.center = self.view.center;
    [mImageView setTRPhoto:mPhoto];
    [mImageView setPictureFrame:YES];
}

- (IBAction)likeButtonPressed:(id)sender {
    if ([mLikeButton.titleLabel.text isEqualToString:@"Like"]) {
        [mLikeButton setTitle:@"Unlike" forState:UIControlStateNormal];
    } else {
        [mLikeButton setTitle:@"Like" forState:UIControlStateNormal];
    }
}

- (IBAction)closePhotoView:(id)sender {
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionFade;

    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - TRGraphDelegate

- (void)graphFinishedUpdating {
    [mUploaderLabel setText:[NSString stringWithFormat:@"%@ %@", mPhoto.uploader.firstName, mPhoto.uploader.lastName]];
    if (mPhoto.numLikes == 1) {
        [mLikeCountLabel setText:@"1 Like"];
    } else {
        [mLikeCountLabel setText:[NSString stringWithFormat:@"%i Likes", mPhoto.numLikes]];
    }
}

@end
