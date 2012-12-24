//
//  TRStreamTableViewController.m
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRStreamTableViewController.h"

#import "TRAppDelegate.h"
#import "TRGraph.h"
#import "TRPhoto.h"
#import "TRPhotoStream.h"
#import "TRUser.h"

#import "TRPhotoStreamViewController.h"
#import "TRStreamCell.h"
#import "TRStreamSetupViewController.h"

@interface TRStreamTableViewController ()

@end

@implementation TRStreamTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"STREAM";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"back"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    [AppDelegate.graph registerForDelegateCallback:self];
    UIBarButtonItem * add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
    [add setBackgroundImage:[UIImage imageNamed:@"navbaritem_orange.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [add setBackgroundImage:[UIImage imageNamed:@"navbaritem_orange_highlighted.png"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [add setTarget:self];
    [add setAction:@selector(presentSetup:)];
    [self.navigationItem setRightBarButtonItem:add];
    [mTableView registerNib:[UINib nibWithNibName:@"TRStreamCell" bundle:nil] forCellReuseIdentifier:@"TRStreamCell"];

    mRefreshControl = [[UIRefreshControl alloc] init];
    [mRefreshControl addTarget:self action:@selector(refreshStreams) forControlEvents:UIControlEventValueChanged];
    [mTableView addSubview:mRefreshControl];
}

- (void)presentSetup:(id)sender {
    TRStreamSetupViewController * setup = [[TRStreamSetupViewController alloc] initWithNibName:@"TRStreamSetupViewController" bundle:nil];
    [self.navigationController presentViewController:setup animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TRUser * loggedInUser = [AppDelegate.graph getUserWithPhone:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]];
    return [loggedInUser.streams count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TRStreamCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TRStreamCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"TRStreamCell" owner:self options:nil][0];
    }

    TRUser * loggedInUser = [AppDelegate.graph getUserWithPhone:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]];
    TRPhotoStream * stream = [loggedInUser.streams objectAtIndex:indexPath.row];
    [cell.titleLabel setText:stream.name];
    if (stream.numParticipants == 1) {
        [cell.participantsLabel setText:@"1 Participant"];
    } else {
        [cell.participantsLabel setText:[NSString stringWithFormat:@"%i Participants", stream.numParticipants]];
    }
    if (stream.numPhotos == 1) {
        [cell.photosLabel setText:@"1 Photo"];
    } else {
        [cell.photosLabel setText:[NSString stringWithFormat:@"%i Photos", stream.numPhotos]];
    }
    if (stream.numPhotos > 0) {
        [cell setPhoto:[stream.photos objectAtIndex:0]];
    } else {
        [cell setBlankPhoto];
    }

    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TRUser * loggedInUser = [AppDelegate.graph getUserWithPhone:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]];
    TRPhotoStream * stream = [loggedInUser.streams objectAtIndex:indexPath.row];
    TRPhotoStreamViewController * streamController = [[TRPhotoStreamViewController alloc] initWithPhotoStream:stream];
    [self.navigationController pushViewController:streamController animated:YES];
}

#pragma mark - TRGraph 

- (void)graphFinishedUpdating {
    if (mRefreshControl) {
        [mRefreshControl endRefreshing];
    }
    [mTableView reloadData];
}

- (void)refreshStreams {
    [AppDelegate.graph downloadUserPhotoStreams:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]];
}

@end
