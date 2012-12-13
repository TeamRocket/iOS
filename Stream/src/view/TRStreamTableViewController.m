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

#import "TRStreamCell.h"

@interface TRStreamTableViewController ()

@end

@implementation TRStreamTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [AppDelegate.graph registerForDelegateCallback:self];
    [AppDelegate.graph downloadUserPhotoStreams:@"18585238764"];
    self.title = @"STREAMS";
    UIBarButtonItem * add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
    [add setBackgroundImage:[UIImage imageNamed:@"navbaritem_orange.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.navigationItem setRightBarButtonItem:add];
    [mTableView registerNib:[UINib nibWithNibName:@"TRStreamCell" bundle:nil] forCellReuseIdentifier:@"TRStreamCell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TRStreamCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TRStreamCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"TRStreamCell" owner:self options:nil][0];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - TRGraph 

- (void)graphFinishedUpdating {
    [mTableView reloadData];
}

@end
