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
#import "TRPhotoStream.h"

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

    [mScroller setContentSize:CGSizeMake(self.view.frame.size.width * 3, IMAGE_SIZE)];
    [TestFlight passCheckpoint:@"Viewed Picture"];
}

- (void)setPhotoView:(TRImageView*)photoView {
    mPhoto = photoView.TRPhoto;
    [AppDelegate.graph registerForDelegateCallback:self];
    [AppDelegate.graph downloadPhotoInfo:mPhoto.ID];
    [AppDelegate.graph downloadLikesForPhoto:mPhoto.ID];
    mImageView = photoView;
    [self.view addSubview:photoView];
}

- (void)setPrevPhoto:(TRPhoto *)prev {
    mPrevPhoto = prev;
    if (mPrevView != nil) {
        [mPrevView removeFromSuperview];
    }
    mPrevView = nil;
    if (mPrevPhoto != nil) {
        [AppDelegate.graph registerForDelegateCallback:self];
        [AppDelegate.graph downloadPhotoInfo:mPrevPhoto.ID];
        [AppDelegate.graph downloadLikesForPhoto:mPrevPhoto.ID];
        mPrevView = [[TRImageView alloc] initWithTRPhoto:mPrevPhoto
                                                 inFrame:CGRectMake(mImageView.frame.origin.x - self.view.frame.size.width,
                                                                    mImageView.frame.origin.y,
                                                                    mImageView.frame.size.width, mImageView.frame.size.height)];
        [mScroller addSubview:mPrevView];
        [mScroller setContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, mScroller.contentInset.right)];
    } else {
        mPrevView = nil;
        [mScroller setContentInset:UIEdgeInsetsMake(0.0, -mScroller.frame.size.width, 0.0, mScroller.contentInset.right)];
    }
}

- (void)setNextPhoto:(TRPhoto *)next {
    mNextPhoto = next;
    if (mNextView != nil) {
        [mNextView removeFromSuperview];
    }
    mNextView = nil;
    if (mNextPhoto != nil) {
        [AppDelegate.graph registerForDelegateCallback:self];
        [AppDelegate.graph downloadPhotoInfo:mNextPhoto.ID];
        [AppDelegate.graph downloadLikesForPhoto:mNextPhoto.ID];
        mNextView = [[TRImageView alloc] initWithTRPhoto:mNextPhoto
                                                 inFrame:CGRectMake(mImageView.frame.origin.x + self.view.frame.size.width,
                                                                    mImageView.frame.origin.y,
                                                                    mImageView.frame.size.width, mImageView.frame.size.height)];
        [mScroller addSubview:mNextView];
        [mScroller setContentInset:UIEdgeInsetsMake(0.0, mScroller.contentInset.left, 0.0, 0.0)];
    } else {
        mNextView = nil;
        [mScroller setContentInset:UIEdgeInsetsMake(0.0, mScroller.contentInset.left, 0.0, -mScroller.frame.size.width)];
    }
}

- (void)setPhotoStream:(TRPhotoStream*)stream {
    mStream = stream;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [mScroller scrollRectToVisible:CGRectMake(mScroller.frame.size.width, 0.0, mScroller.frame.size.width, mScroller.frame.size.height) animated:NO];

    if ([mLikeCountButton.titleLabel.text length] == 0) {
        [UIView beginAnimations:@"PhotoScaleFull" context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(loadFullImage)];
        //mImageView.center = CGPointMake(self.view.center.x + self.view.frame.size.width,
        //                                self.view.center.y - mScroller.frame.origin.y);
        mImageView.center = self.view.center;
        [mImageView setTransform:CGAffineTransformMakeScale(IMAGE_SIZE/mImageView.frame.size.width,
                                                            IMAGE_SIZE/mImageView.frame.size.height)];
        [UIView commitAnimations];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [AppDelegate.graph unregisterForDelegateCallback:self];
}

- (void)loadFullImage {
    [mImageView setTransform:CGAffineTransformMakeScale(1.0f,
                                                        1.0f)];
    [mImageView setFrame:CGRectMake(0.0, 0.0, IMAGE_SIZE, IMAGE_SIZE)];
    [mImageView removeFromSuperview];
    [mScroller addSubview:mImageView];
    mImageView.center = CGPointMake(mScroller.contentSize.width/2, self.view.center.y - mScroller.frame.origin.y);
    [mImageView setTRPhoto:mPhoto];

    [self setPrevPhoto:[mStream photoBefore:mPhoto]];
    [self setNextPhoto:[mStream photoAfter:mPhoto]];
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
        [AppDelegate.graph sendLikePhoto:mPhoto.ID
                                forPhone:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]];
        [mPhoto addLiker:me];
        mPhoto.numLikes++;
    } else {
        [mLikeButton setTitle:@"Like" forState:UIControlStateNormal];
        [mLikeOverlayImage setImage:[UIImage imageNamed:@"heart_unlike_large.png"]];
        [mLikeOverlayLabel setText:@"Unliked..."];
        [mLikeIndicator setImage:[UIImage imageNamed:@"heart_white_small.png"]];
        [mPhoto removeLiker:me];
        [AppDelegate.graph sendUnlikePhoto:mPhoto.ID
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
    if ([mPhoto.likers containsObject:AppDelegate.graph.me]) {
        [mLikeIndicator setImage:[UIImage imageNamed:@"heart_red_small.png"]];
        [mLikeButton setTitle:@"Unlike" forState:UIControlStateNormal];
    } else {
        [mLikeIndicator setImage:[UIImage imageNamed:@"heart_white_small.png"]];
        [mLikeButton setTitle:@"Like" forState:UIControlStateNormal];
    }
    if (mPrevPhoto != [mStream photoBefore:mPhoto]) {
        [self setPrevPhoto:[mStream photoBefore:mPhoto]];
    }
    if (mNextPhoto != [mStream photoAfter:mPhoto]) {
        [self setNextPhoto:[mStream photoAfter:mPhoto]];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollToIndex:(int)index animated:(BOOL)animated {
    if (index < 0)
        index = 0;
    else if (index >= 3)
        index = 2;
    if (index == 0 && mScroller.contentInset.left != 0.0f) {
        index = 1;
    }
    if (index == 2 && mScroller.contentInset.right != 0.0f) {
        index = 1;
    }
    [mScroller scrollRectToVisible:CGRectMake(index*mScroller.frame.size.width, 0.0, mScroller.frame.size.width, IMAGE_SIZE) animated:animated];
    mCurrentIndex = index;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    CGPoint offset = scrollView.contentOffset;
    *targetContentOffset = offset;
    if (velocity.x > 0.5) {
        [self scrollToIndex:2 animated:YES];
    } else if (velocity.x < -0.5) {
        [self scrollToIndex:0 animated:YES];
    } else {
        [self scrollToIndex:(int)round(offset.x/mScroller.frame.size.width) animated:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    switch (mCurrentIndex) {
        case 0:
            mPhoto = mPrevPhoto;
            [self setPrevPhoto:[mStream photoBefore:mPhoto]];
            [self setNextPhoto:[mStream photoAfter:mPhoto]];
            [mImageView setTRPhoto:mPhoto];
            [mUploaderLabel setText:@""];
            break;
        case 2:
            mPhoto = mNextPhoto;
            [self setPrevPhoto:[mStream photoBefore:mPhoto]];
            [self setNextPhoto:[mStream photoAfter:mPhoto]];
            [mImageView setTRPhoto:mPhoto];
            [mUploaderLabel setText:@""];
            [mLikeCountButton setTitle:@"" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    [self scrollToIndex:1 animated:NO];
}

@end
