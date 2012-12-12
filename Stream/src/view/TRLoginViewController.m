//
//  TRLoginViewController.m
//  Stream
//
//  Created by Peter Tsoi on 12/11/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TRLoginViewController.h"

#import "TRTableViewCell.h"

@interface TRLoginViewController ()

@end

@implementation TRLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)pressedBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pressedSignin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [mNavBar setBackgroundImage:[UIImage imageNamed:@"navbarbg.png"] forBarMetrics:UIBarMetricsDefault];
    [mNavBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"MuseoSans-300" size:22.0], UITextAttributeFont, nil]];

    [mBackBtn setBackgroundImage:[UIImage imageNamed:@"navbarback.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [mBackBtn setTitlePositionAdjustment:UIOffsetMake(5.0f, 0.0f) forBarMetrics:UIBarMetricsDefault];
    [mBackBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"MuseoSans-500" size:11.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
    [mSigninBtn setBackgroundImage:[UIImage imageNamed:@"navbaritem.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [mSigninBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"MuseoSans-500" size:11.0], UITextAttributeFont, nil] forState:UIControlStateNormal];

}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TRTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TRTextFieldCell"];
    if (!cell)
        cell = [[TRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TRTextFieldCell"];
        
    int sectionRows = [tableView numberOfRowsInSection:[indexPath section]];
    if (indexPath.row == 0 && indexPath.row == sectionRows - 1) {
        [cell setCapType:TRTableViewCellCapTypeTopBot];
    } else if (indexPath.row == 0) {
        [cell setCapType:TRTableViewCellCapTypeTop];
    } else if (indexPath.row == sectionRows - 1) {
        [cell setCapType:TRTableViewCellCapTypeBot];
    } else {
        [cell setCapType:TRTableViewCellCapTypeNone];
    }
    return cell;
}

@end
