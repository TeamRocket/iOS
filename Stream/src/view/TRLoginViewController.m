//
//  TRLoginViewController.m
//  Stream
//
//  Created by Peter Tsoi on 12/11/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRLoginViewController.h"

#import "TRAppDelegate.h"
#import "TRUser.h"

#import "TRSplashViewController.h"
#import "TRTextFieldCell.h"

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
    [AppDelegate.graph registerForDelegateCallback:self];
    [AppDelegate.graph loginAsUser:mUsernameField.text password:mPasswordField.text];
}

- (void)dismissSplash {
    TRSplashViewController * splash = (TRSplashViewController*)self.presentingViewController;
    [self dismissViewControllerAnimated:YES completion:^{[splash authenitcated];}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [mBackBtn setBackgroundImage:[UIImage imageNamed:@"navbarback.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [mBackBtn setBackgroundImage:[UIImage imageNamed:@"navbarback_highlighted.png"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [mBackBtn setTitlePositionAdjustment:UIOffsetMake(5.0f, 0.0f) forBarMetrics:UIBarMetricsDefault];
    [mBackBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"MuseoSans-500" size:11.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TRTextFieldCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TRTextFieldCell"];
    if (!cell)
        cell = [[NSBundle mainBundle] loadNibNamed:@"TRTextFieldCell" owner:self options:nil][0];
        
    int sectionRows = [tableView numberOfRowsInSection:[indexPath section]];
    if (indexPath.row == 0) {
        [cell setCapType:TRTableViewCellCapTypeTop];
        [cell.textField setPlaceholder:@"Phone Number"];
        [cell.textField setKeyboardType:UIKeyboardTypePhonePad];
        [cell.textField setText:@""];
        mUsernameField = cell.textField;
    } else if (indexPath.row == sectionRows - 1) {
        [cell setCapType:TRTableViewCellCapTypeBot];
        [cell.textField setPlaceholder:@"Password"];
        [cell.textField setText:@""];
        [cell.textField setSecureTextEntry:YES];
        mPasswordField = cell.textField;
    }
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"WELCOME BACK";
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 36.0)];
    tableView.sectionHeaderHeight = headerView.frame.size.height;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.font = [UIFont boldSystemFontOfSize:16.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.shadowOffset = CGSizeMake(0, 1);
    label.shadowColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:0.298 green:0.2980 blue:0.2980 alpha:1.000];

    label.center = headerView.center;

    [headerView addSubview:label];

    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, tableView.bounds.size.width, tableView.sectionFooterHeight)];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    label.text = [self tableView:tableView titleForFooterInSection:section];
    label.font = [UIFont systemFontOfSize:13.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.shadowOffset = CGSizeMake(0, 1);
    label.shadowColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithWhite:0.4f alpha:1.0];

    label.center = footerView.center;

    [footerView addSubview:label];
    return footerView;
}


- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)graphFinishedUpdating {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]) {
        [AppDelegate.graph downloadUserPhotoStreams:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]];
        [self dismissSplash];
        [AppDelegate.graph unregisterForDelegateCallback:self];
        [TestFlight passCheckpoint:@"Logged In"];
        [[Mixpanel sharedInstance] track:@"Sign In"];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Signin Error" message:@"You entered an incorrect phone number or password." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

@end
