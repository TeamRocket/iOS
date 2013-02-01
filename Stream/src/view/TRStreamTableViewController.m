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

#import "TRFeedbackViewController.h"
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
    mWasPreviouslyCreatingStream = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStreams) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshStreams];
}

- (void)presentSetup:(id)sender {
    TRStreamSetupViewController * setup = [[TRStreamSetupViewController alloc] initWithStream:nil];
    mWasPreviouslyCreatingStream = YES;
    [self.navigationController presentViewController:setup animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([AppDelegate.graph.me.streams count] > 0)
        return 2;
    else 
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [AppDelegate.graph.me.streams count];
    } else {
        return 1;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TRStreamCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TRStreamCell"];
        if (cell == nil) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"TRStreamCell" owner:self options:nil][0];
        }

        TRPhotoStream * stream = [AppDelegate.graph.me.streams objectAtIndex:indexPath.row];
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
    } else {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        }
        [cell.textLabel setText:@"Send Feedback"];
        [cell.textLabel setTextColor:[UIColor colorWithWhite:0.6 alpha:1.0]];
        [cell.textLabel setShadowColor:[UIColor whiteColor]];
        [cell.textLabel setShadowOffset:CGSizeMake(0.0, 1.0)];
        [cell.textLabel setFont:[UIFont fontWithName:@"MuseoSans-700" size:13.0f]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell setSelectionStyle:UITableViewCellEditingStyleNone];
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TRPhotoStream * stream = [AppDelegate.graph.me.streams objectAtIndex:indexPath.row];
        TRPhotoStreamViewController * streamController = [[TRPhotoStreamViewController alloc] initWithPhotoStream:stream];
        [self.navigationController pushViewController:streamController animated:YES];
    } else {
        TRFeedbackViewController * feedback = [[TRFeedbackViewController alloc] initWithNibName:@"TRFeedbackViewController" bundle:nil];
        [self presentViewController:feedback animated:YES completion:nil];
    }

}

#pragma mark - TRGraph 

- (void)graphFinishedUpdating {
    if (mRefreshControl) {
        [mRefreshControl endRefreshing];
    }
    if (mWasPreviouslyCreatingStream) {
        [self refreshStreams];
        mWasPreviouslyCreatingStream = NO;
    }
    [mTableView reloadData];
}

- (void)refreshStreams {
    [AppDelegate.graph downloadUserPhotoStreams:AppDelegate.graph.me.phone];
}

@end
