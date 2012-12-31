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
#import "TRUser.h"

#import "TRImageView.h"
#import "TRStreamGridViewCell.h"
#import "TRParticipantsViewController.h"
#import "TRPhotoViewController.h"

#define MAX_UPLOAD_DIMENTION 1024

@interface TRPhotoStreamViewController ()

@end

@implementation TRPhotoStreamViewController

- (id)initWithPhotoStream:(TRPhotoStream *)stream mode:(TRPhotoStreamViewMode)mode{
    self = [super initWithNibName:@"TRPhotoStreamViewController" bundle:nil];
    if (self) {
        mStream = stream;
        mMode = mode;
        self.title = mStream.name;
        [AppDelegate.graph registerForDelegateCallback:self];
        if (mMode == kTRPhotoStreamViewModeAll) {
            [AppDelegate.graph downloadStreamInfo:mStream.ID
                                         forPhone:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]];
        } else {
            [AppDelegate.graph downloadUserPhotos:mUser.phone
                                         inStream:mStream.ID];
        }

        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"back"
                                                                                 style:UIBarButtonItemStyleBordered
                                                                                target:nil
                                                                                action:nil];
    }
    return self;
}

- (id)initWithPhotoStream:(TRPhotoStream *)stream forUser:(TRUser *)user {
    mUser = user;
    self = [self initWithPhotoStream:stream mode:kTRPhotoStreamViewModeUserFilter];
    if (self) {
        
    }
    [TestFlight passCheckpoint:@"Viewed Stream by User"];
    return self;
}

- (id)initWithPhotoStream:(TRPhotoStream *)stream{
    self = [self initWithPhotoStream:stream mode:kTRPhotoStreamViewModeAll];
    [TestFlight passCheckpoint:@"Viewed Stream"];
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    if (mMode == kTRPhotoStreamViewModeAll) {
        UIBarButtonItem * add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:nil action:nil];
        [add setBackgroundImage:[UIImage imageNamed:@"navbaritem_orange.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [add setBackgroundImage:[UIImage imageNamed:@"navbaritem_orange_highlighted.png"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        [add setTarget:self];
        [add setAction:@selector(showPhotoPicker)];
        [mTableView registerNib:[UINib nibWithNibName:@"TRStreamGridViewCell" bundle:nil] forCellReuseIdentifier:@"TRStreamGridViewCell"];
        [self.navigationItem setRightBarButtonItem:add];
    }
    if (mRefreshControl == nil) {
        mRefreshControl = [[UIRefreshControl alloc] init];
        [mRefreshControl addTarget:self action:@selector(refreshStream) forControlEvents:UIControlEventValueChanged];
        [mTableView addSubview:mRefreshControl];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPhotoPicker {
    if (!mPicker) {
        mPicker = [[UIImagePickerController alloc] init];
        [mPicker setDelegate:self];
    }
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [mPicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        [self presentViewController:mPicker animated:YES completion:nil];
    } else {
        UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:@"Take Photo", @"Choose Existing", nil];

        popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [popupQuery showInView:self.view];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    else {
        if (mMode == kTRPhotoStreamViewModeAll) {
            return (mStream.numPhotos + 2 - 1)/2;
        } else {
            return ([mUser getCountOfPhotosInStream:mStream] + 2 - 1)/2;
        }
    }
        
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            if (mMode == kTRPhotoStreamViewModeAll) {
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
                [participantsButton addTarget:self action:@selector(tappedParticipantsButton:) forControlEvents:UIControlEventTouchUpInside];
                UIImageView * participants = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"participants.png"]];
                [participantsButton.titleLabel addSubview:participants];
                [cell addSubview:participantsButton];
            } else if (mMode == kTRPhotoStreamViewModeUserFilter) {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width-40, 18)];
                label.text = [NSString stringWithFormat:@"%@ %@'s photos", mUser.firstName, mUser.lastName];
                label.font = [UIFont boldSystemFontOfSize:16.0];
                label.shadowOffset = CGSizeMake(0, 1);
                label.shadowColor = [UIColor whiteColor];
                label.backgroundColor = [UIColor clearColor];
                label.textColor = [UIColor colorWithRed:0.298 green:0.2980 blue:0.2980 alpha:1.000];
                
                label.center = cell.center;
                [cell addSubview:label];
            }
        }
        return cell;
    } else {
        NSArray * photoArray = mMode == kTRPhotoStreamViewModeAll ? mStream.photos : [mUser photosInStream:mStream];
        cell = [tableView dequeueReusableCellWithIdentifier:@"TRStreamGridViewCell"];
        if (cell == nil) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"TRStreamGridViewCell" owner:self options:nil][0];
        }
        TRStreamGridViewCell * gridCell = (TRStreamGridViewCell*)cell;
        if ([photoArray count] > 0) {
            if (indexPath.row * 2 < [photoArray count]) {
                TRPhoto * leftPhoto = [photoArray objectAtIndex:(indexPath.row * 2)];
                [gridCell.leftFrame setTRPhoto:leftPhoto];
                if (!gridCell.leftFrame.tapRecognizer)
                    gridCell.leftFrame.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedPhoto:)];
                else
                    [gridCell.leftFrame.tapRecognizer addTarget:self action:@selector(tappedPhoto:)];
                [gridCell.leftFrame setUserInteractionEnabled:YES];
                [gridCell.leftFrame.tapRecognizer setNumberOfTapsRequired:1];
                [gridCell.leftFrame setAlpha:1.0f];
            }
            if (indexPath.row * 2 + 1 < [photoArray count]) {
                TRPhoto * rightPhoto = [photoArray objectAtIndex:(indexPath.row * 2) + 1];
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
        switch (mMode) {
            case kTRPhotoStreamViewModeAll:
                return 65.0f; 
                break;
            case kTRPhotoStreamViewModeUserFilter:
                return 35.0f;
            default:
                return 0.0f;
                break;
        }
    } else {
        return 155.0f;
    }
}

- (void)tappedPhoto:(UITapGestureRecognizer*)recognizer {
    TRImageView * frame = (TRImageView*)recognizer.view;
    TRPhotoViewController * photoView = [[TRPhotoViewController alloc] initWithNibName:@"TRPhotoViewController" bundle:nil];
    [photoView setPhotoStream:mStream];
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

- (void)tappedParticipantsButton:(id)sender {
    TRParticipantsViewController * participants = [[TRParticipantsViewController alloc] initWithStream:mStream];
    [self.navigationController pushViewController:participants animated:YES];
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
    TRPhoto * newPhoto = [[TRPhoto alloc] initWithID:nil
                                                 URL:nil
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

    newPhoto.image = [TRImage orientImage:image];
    [AppDelegate.graph uploadPhoto:newPhoto toStream:mStream];
    [self dismissViewControllerAnimated:YES completion:nil];
    [TestFlight passCheckpoint:@"Uploaded Picture"];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate 

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            mPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:mPicker animated:YES completion:nil];
            break;
        case 1:
            mPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:mPicker animated:YES completion:nil];
            break;
        default:
            break;
    }
}

@end
