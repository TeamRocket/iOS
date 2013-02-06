//
//  TRParticipantsViewController.m
//  Stream
//
//  Created by Peter Tsoi on 12/23/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRParticipantsViewController.h"

#import "TRAppDelegate.h"
#import "TRPhotoStream.h"
#import "TRUser.h"

#import "TRStreamSetupViewController.h"
#import "TRParticipantCell.h"
#import "TRPhotoStreamViewController.h"

@interface TRParticipantsViewController ()

@end

@implementation TRParticipantsViewController

- (id)initWithStream:(TRPhotoStream*)stream { 
    self = [super initWithNibName:@"TRParticipantsViewController" bundle:nil];
    if (self) {
        self.title = @"PARTICIPANTS";
        mStream = stream;
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"back"
                                                                                 style:UIBarButtonItemStyleBordered
                                                                                target:nil
                                                                                action:nil];
    }
    [TestFlight passCheckpoint:@"Viewed Participants"];
    [[Mixpanel sharedInstance] track:@"View Participants"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [mTableView registerNib:[UINib nibWithNibName:@"TRParticipantCell" bundle:nil] forCellReuseIdentifier:@"TRParticipantCell"];
    [AppDelegate.graph registerForDelegateCallback:self];
    [AppDelegate.graph downloadParticipantsInStream:mStream.ID];
    UIBarButtonItem * add = [[UIBarButtonItem alloc] initWithTitle:@"invite" style:UIBarButtonItemStylePlain target:self action:nil];
    [add setBackgroundImage:[UIImage imageNamed:@"navbaritem_orange.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [add setBackgroundImage:[UIImage imageNamed:@"navbaritem_orange_highlighted.png"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [add setTarget:self];
    [add setAction:@selector(presentSetup:)];
    [self.navigationItem setRightBarButtonItem:add];
    if (mRefreshControl == nil) {
        mRefreshControl = [[UIRefreshControl alloc] init];
        [mRefreshControl addTarget:self action:@selector(refreshParticipants) forControlEvents:UIControlEventValueChanged];
        [mTableView addSubview:mRefreshControl];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mStream.participants count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TRParticipantCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TRParticipantCell"];
    if (!cell)
        cell = [[NSBundle mainBundle] loadNibNamed:@"TRParticipantCell" owner:self options:nil][0];

    TRUser * user = [mStream.participants objectAtIndex:indexPath.row];
    [cell setUser:user];
    [cell setNumPhotos:[user getCountOfPhotosInStream:mStream]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TRPhotoStreamViewController * streamView = [[TRPhotoStreamViewController alloc] initWithPhotoStream:mStream forUser:[mStream.participants objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:streamView animated:YES];
}

- (void)graphFinishedUpdating {
    if (mRefreshControl) {
        [mRefreshControl endRefreshing];
    }
    [mTableView reloadData];
}

- (void)presentSetup:(id)sender {
    TRStreamSetupViewController * setup = [[TRStreamSetupViewController alloc] initWithStream:mStream];
    [self presentViewController:setup animated:YES completion:nil];
}

- (void)refreshParticipants {
    [AppDelegate.graph downloadParticipantsInStream:mStream.ID];
}

@end
