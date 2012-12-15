//
//  TRPhotoStreamViewController.m
//  Stream
//
//  Created by Peter Tsoi on 12/13/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRPhotoStreamViewController.h"

#import "TRAppDelegate.h"
#import "TRPhoto.h"
#import "TRPhotoStream.h"

#import "TRImageView.h"
#import "TRStreamGridViewCell.h"

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
                [gridCell.leftFrame setAlpha:1.0f];
            }
            if (indexPath.row * 2 + 1 < [mStream.photos count]) {
                TRPhoto * rightPhoto = [mStream.photos objectAtIndex:(indexPath.row * 2) + 1];
                [gridCell.rightFrame setTRPhoto:rightPhoto];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
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

@end
