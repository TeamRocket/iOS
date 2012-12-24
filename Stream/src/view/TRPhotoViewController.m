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
#import "TRLikerListViewController.h"
#import "TRPhoto.h"
#import "TRUser.h"

#define IMAGE_SIZE 300.0f

@interface TRPhotoViewController ()

@end

@implementation TRPhotoViewController

- (void)viewDidLoad {
    [mUploaderLabel setFont:[UIFont fontWithName:@"MuseoSans-300" size:22.0]];
    [mLikeButton.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:20.0]];
    [mLikeCountButton.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:20.0]];
    mLikeOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, IMAGE_SIZE - 10.0f, IMAGE_SIZE - 10.0f)];
    [mLikeOverlayView setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.8f]];
    
    mLikeOverlayImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart_red_large.png"]];
    mLikeOverlayImage.center = CGPointMake(mLikeOverlayView.frame.size.width/2,
                                           mLikeOverlayView.frame.size.height/2);
    mLikeOverlayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, mLikeOverlayImage.frame.origin.y + mLikeOverlayImage.frame.size.height + 5.0f, 300.0f, 25.0f)];
    mLikeOverlayLabel.center = CGPointMake(mLikeOverlayImage.center.x, mLikeOverlayLabel.center.y);
    [mLikeOverlayView addSubview:mLikeOverlayImage];
    [mLikeOverlayView addSubview:mLikeOverlayLabel];
    [mLikeOverlayLabel setText:@"Liked!"];
    [mLikeOverlayLabel setTextColor:[UIColor whiteColor]];
    [mLikeOverlayLabel setBackgroundColor:[UIColor clearColor]];
    [mLikeOverlayLabel setTextAlignment:NSTextAlignmentCenter];
    [mLikeOverlayLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:17.0f]];

    [mLikeOverlayView setAlpha:0.0f];
    [self.view addSubview:mLikeOverlayView];

    mLikeIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart_white_small.png"]];
    mLikeIndicator.center = mLikeCountButton.center;
    [self.view addSubview:mLikeIndicator];
    [TestFlight passCheckpoint:@"Viewed Picture"];
}

- (void)setPhotoView:(TRImageView*)photoView {
    mPhoto = photoView.TRPhoto;
    [AppDelegate.graph registerForDelegateCallback:self];
    [AppDelegate.graph downloadPhotoInfo:[mPhoto.URL absoluteString]];
    [AppDelegate.graph downloadLikesForPhoto:[mPhoto.URL absoluteString]];
    mImageView = photoView;
    [self.view addSubview:photoView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

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
    mLikeOverlayView = nil;
    mLikeOverlayImage = nil;
    mLikeOverlayLabel = nil;
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
    mLikeOverlayView.center = self.view.center;
    [self.view bringSubviewToFront:mLikeOverlayView];
    TRUser * me = [AppDelegate.graph getUserWithPhone:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]];
    
    if ([mLikeButton.titleLabel.text isEqualToString:@"Like"]) {
        [mLikeButton setTitle:@"Unlike" forState:UIControlStateNormal];
        [mLikeOverlayImage setImage:[UIImage imageNamed:@"heart_red_large.png"]];
        [mLikeOverlayLabel setText:@"Liked!"];
        [mLikeIndicator setImage:[UIImage imageNamed:@"heart_red_small.png"]];
        [AppDelegate.graph sendLikePhoto:[mPhoto.URL absoluteString]
                                forPhone:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]];
        [mPhoto addLiker:me];
        mPhoto.numLikes++;
    } else {
        [mLikeButton setTitle:@"Like" forState:UIControlStateNormal];
        [mLikeOverlayImage setImage:[UIImage imageNamed:@"heart_unlike_large.png"]];
        [mLikeOverlayLabel setText:@"Unliked..."];
        [mLikeIndicator setImage:[UIImage imageNamed:@"heart_white_small.png"]];
        [mPhoto removeLiker:me];
        [AppDelegate.graph sendUnlikePhoto:[mPhoto.URL absoluteString]
                                  forPhone:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]];
        mPhoto.numLikes--;
    }
    [self graphFinishedUpdating];

    CAKeyframeAnimation *fadeInAndOut = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    fadeInAndOut.duration = 2.0f;
    fadeInAndOut.keyTimes = [NSArray arrayWithObjects:  [NSNumber numberWithFloat:0.0],
                             [NSNumber numberWithFloat:0.075],
                             [NSNumber numberWithFloat:0.80],
                             [NSNumber numberWithFloat:1.0], nil];

    fadeInAndOut.values = [NSArray arrayWithObjects:    [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:1.0],
                           [NSNumber numberWithFloat:1.0],
                           [NSNumber numberWithFloat:0.0], nil];
    fadeInAndOut.timingFunctions = [NSArray arrayWithObjects:
                                    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], nil];
    
    [mLikeOverlayView.layer addAnimation:fadeInAndOut forKey:@"FadeOverlay"];
    [TestFlight passCheckpoint:@"Liked Photo"];
}

- (IBAction)closePhotoView:(id)sender {
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionFade;

    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)showLikers:(id)sender {
    TRLikerListViewController * likers = [[TRLikerListViewController alloc] initWithPhoto:mPhoto];

    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionFade;

    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:likers animated:NO];
}

#pragma mark - TRGraphDelegate

- (void)graphFinishedUpdating {
    [mUploaderLabel setText:[NSString stringWithFormat:@"%@ %@", mPhoto.uploader.firstName, mPhoto.uploader.lastName]];
    if (mPhoto.numLikes == 1) {
        [mLikeCountButton setTitle:@"1 Like" forState:UIControlStateNormal];
    } else {
        [mLikeCountButton setTitle:[NSString stringWithFormat:@"%i Likes", mPhoto.numLikes] forState:UIControlStateNormal];
    }
    CGSize labelSize = [mLikeCountButton.titleLabel.text sizeWithFont:mLikeCountButton.titleLabel.font];
    mLikeIndicator.center = CGPointMake(mLikeCountButton.frame.origin.x + mLikeCountButton.frame.size.width - labelSize.width - mLikeIndicator.frame.size.width, mLikeCountButton.center.y);
    TRUser * me = [AppDelegate.graph getUserWithPhone:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]];
    if ([mPhoto.likers containsObject:me]) {
        [mLikeIndicator setImage:[UIImage imageNamed:@"heart_red_small.png"]];
        [mLikeButton setTitle:@"Unlike" forState:UIControlStateNormal];
    }
}

@end
