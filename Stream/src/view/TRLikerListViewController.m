//
//  TRLikerListViewController.m
//  Stream
//
//  Created by Peter Tsoi on 12/24/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRLikerListViewController.h"

#import "TRPhoto.h"
#import "TRUser.h"

@interface TRLikerListViewController ()

@end

@implementation TRLikerListViewController

- (id)initWithPhoto:(TRPhoto*)photo {
    self = [super initWithNibName:@"TRLikerListViewController" bundle:nil];
    if (self) {
        mPhoto = photo;
        self.title = @"LIKES";
    }
    [TestFlight passCheckpoint:@"Viewed Likers"];
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [mPhoto.likers count];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"LikerCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LikerCell"];
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f]];
        cell.selectedBackgroundView = nil;
    }
    TRUser * liker = [mPhoto.likers objectAtIndex:indexPath.row];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@ %@", liker.firstName, liker.lastName]];
    return cell;
}

@end
