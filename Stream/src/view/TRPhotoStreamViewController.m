//
//  TRPhotoStreamViewController.m
//  Stream
//
//  Created by Peter Tsoi on 12/13/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TRPhotoStreamViewController.h"

#import "TRAppDelegate.h"
#import "TRImage.h"
#import "TRPhoto.h"
#import "TRPhotoStream.h"

#import "TRImageView.h"
#import "TRStreamGridViewCell.h"
#import "TRPhotoViewController.h"

#define MAX_UPLOAD_DIMENTION 1024

@interface TRPhotoStreamViewController ()

@end

@implementation TRPhotoStreamViewController

- (id)initWithPhotoStream:(TRPhotoStream *)stream{
    self = [super initWithNibName:@"TRPhotoStreamViewController" bundle:nil];
    if (self) {
        mStream = stream;
        self.title = mStream.name;
        [AppDelegate.graph registerForDelegateCallback:self];
        [AppDelegate.graph downloadStreamInfo:mStream.ID
                                     forPhone:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    UIBarButtonItem * add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:nil action:nil];
    [add setBackgroundImage:[UIImage imageNamed:@"navbaritem_orange.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [add setBackgroundImage:[UIImage imageNamed:@"navbaritem_orange_highlighted.png"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [add setTarget:self];
    [add setAction:@selector(showPhotoPicker)];
    [mTableView registerNib:[UINib nibWithNibName:@"TRStreamGridViewCell" bundle:nil] forCellReuseIdentifier:@"TRStreamGridViewCell"];
    [self.navigationItem setRightBarButtonItem:add];

    mRefreshControl = [[UIRefreshControl alloc] init];
    [mRefreshControl addTarget:self action:@selector(refreshStream) forControlEvents:UIControlEventValueChanged];
    [mTableView addSubview:mRefreshControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPhotoPicker {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    [picker setDelegate:self];
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return (mStream.numPhotos + 2 - 1)/2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        }
        UIButton * participantsButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 300.0f, 46.0f)];
        [participantsButton setBackgroundImage:[UIImage imageNamed:@"view_participants_normal.png"] forState:UIControlStateNormal];
        [participantsButton setBackgroundImage:[UIImage imageNamed:@"view_participants_highlighted.png"] forState:UIControlStateSelected];
        if (mStream.numParticipants == 1) {
            [participantsButton setTitle:@"       1 Participant" forState:UIControlStateNormal];
        } else {
            [participantsButton setTitle:[NSString stringWithFormat:@"       %i Participants", mStream.numParticipants] forState:UIControlStateNormal];
        }
        
        [participantsButton setTitleColor:[UIColor colorWithRed:0.281f green:0.285f blue:0.297f alpha:1.0] forState:UIControlStateNormal];
        [participantsButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f]];
        [participantsButton setTitleShadowColor:[UIColor colorWithWhite:1.0 alpha:0.5] forState:UIControlStateNormal];
        [participantsButton.titleLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
        UIImageView * participants = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"participants.png"]];
        [participantsButton.titleLabel addSubview:participants];
        [cell addSubview:participantsButton];
        return cell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TRStreamGridViewCell"];
        TRStreamGridViewCell * gridCell = (TRStreamGridViewCell*)cell;
        if ([mStream.photos count] > 0) {
            if (indexPath.row * 2 < [mStream.photos count]) {
                TRPhoto * leftPhoto = [mStream.photos objectAtIndex:(indexPath.row * 2)];
                [gridCell.leftFrame setTRPhoto:leftPhoto];
                if (!gridCell.leftFrame.tapRecognizer)
                    gridCell.leftFrame.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedPhoto:)];
                else
                    [gridCell.leftFrame.tapRecognizer addTarget:self action:@selector(tappedPhoto:)];
                [gridCell.leftFrame setUserInteractionEnabled:YES];
                [gridCell.leftFrame.tapRecognizer setNumberOfTapsRequired:1];
                [gridCell.leftFrame setAlpha:1.0f];
            }
            if (indexPath.row * 2 + 1 < [mStream.photos count]) {
                TRPhoto * rightPhoto = [mStream.photos objectAtIndex:(indexPath.row * 2) + 1];
                [gridCell.rightFrame setTRPhoto:rightPhoto];
                if (!gridCell.rightFrame.tapRecognizer)
                    gridCell.rightFrame.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedPhoto:)];
                else
                    [gridCell.rightFrame.tapRecognizer addTarget:self action:@selector(tappedPhoto:)];
                [gridCell.rightFrame setAlpha:1.0f];
            } else {
                [gridCell.rightFrame setAlpha:0.0f];
            }
        } else {
            [gridCell.leftFrame setAlpha:0.0f];
            [gridCell.rightFrame setAlpha:0.0f];
        }
        
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 65.0f; 
    } else {
        return 155.0f;
    }
}

- (void)tappedPhoto:(UITapGestureRecognizer*)recognizer {
    TRImageView * frame = (TRImageView*)recognizer.view;
    TRPhotoViewController * photoView = [[TRPhotoViewController alloc] initWithNibName:@"TRPhotoViewController" bundle:nil];
    [photoView.view setBackgroundColor:[UIColor blackColor]];
    TRImageView * largeFrame = [[TRImageView alloc] initWithTRPhoto:frame.TRPhoto
                                                            inFrame:[frame.superview convertRect:frame.frame toView:self.view]];
    [largeFrame setPictureFrame:YES];
    largeFrame.center = CGPointMake(largeFrame.center.x,
                                    largeFrame.center.y + self.navigationController.navigationBar.frame.size.height);
    [photoView setPhotoView:largeFrame];

    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionFade;

    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController pushViewController:photoView animated:NO];
}

#pragma mark - TRGraphDelegate

- (void)graphFinishedUpdating {
    if (mRefreshControl) {
        [mRefreshControl endRefreshing];
    }
    [mTableView reloadData];
}

- (void)refreshStream {
    [AppDelegate.graph downloadStreamInfo:mStream.ID
                                 forPhone:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    TRPhoto * newPhoto = [[TRPhoto alloc] initWithURL:nil
                                             uploader:[AppDelegate.graph getUserWithPhone:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]]];
    TRImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if(!image)
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    float aspect = image.size.width/image.size.height;
    if (aspect > 1) {
        if (image.size.width > MAX_UPLOAD_DIMENTION) {
            image = [TRImage imageWithImage:image scaledToSize:CGSizeMake(MAX_UPLOAD_DIMENTION, MAX_UPLOAD_DIMENTION/aspect)];
        }
    } else  {
        if (image.size.height > MAX_UPLOAD_DIMENTION) {
            image = [TRImage imageWithImage:image scaledToSize:CGSizeMake(MAX_UPLOAD_DIMENTION*aspect, MAX_UPLOAD_DIMENTION)];
        }
    }
    newPhoto.image = image;
    [AppDelegate.graph uploadPhoto:newPhoto toStream:mStream];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
