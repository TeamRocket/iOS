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

#import "TRParticipantCell.h"

@interface TRParticipantsViewController ()

@end

@implementation TRParticipantsViewController

- (id)initWithStream:(TRPhotoStream*)stream { 
    self = [super initWithNibName:@"TRParticipantsViewController" bundle:nil];
    if (self) {
        self.title = @"PARTICIPANTS";
        mStream = stream;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [mTableView registerNib:[UINib nibWithNibName:@"TRParticipantCell" bundle:nil] forCellReuseIdentifier:@"TRParticipantCell"];
    [AppDelegate.graph registerForDelegateCallback:self];
    [AppDelegate.graph downloadParticipantsInStream:mStream.ID];
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

- (void)graphFinishedUpdating {
    if (mRefreshControl) {
        [mRefreshControl endRefreshing];
    }
    [mTableView reloadData];
}

- (void)refreshParticipants {
    [AppDelegate.graph downloadParticipantsInStream:mStream.ID];
}

@end
