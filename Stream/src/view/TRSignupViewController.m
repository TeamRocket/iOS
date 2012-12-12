//
//  TRSignupViewController.m
//  Stream
//
//  Created by Peter Tsoi on 12/12/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRSignupViewController.h"

#import "TRTextFieldCell.h"

@interface TRSignupViewController ()

@end

@implementation TRSignupViewController

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

- (IBAction)pressedSignup:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

-(void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self keyboardWillBeHidden:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    mTableView.contentInset = contentInsets;
    mTableView.scrollIndicatorInsets = contentInsets;

    CGRect aRect = mTableView.frame;
    aRect.size.height -= kbSize.height;
    if ([mActiveField.placeholder isEqualToString:@"Password"] || [mActiveField.placeholder isEqualToString:@"Confirm Password"]) {
        [mTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
    mActiveField = textField;
    return YES;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    mTableView.contentInset = contentInsets;
    mTableView.scrollIndicatorInsets = contentInsets;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [mNavBar setBackgroundImage:[UIImage imageNamed:@"navbarbg.png"] forBarMetrics:UIBarMetricsDefault];
    [mNavBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"MuseoSans-300" size:22.0], UITextAttributeFont, nil]];

    [mBackBtn setBackgroundImage:[UIImage imageNamed:@"navbarback.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [mBackBtn setTitlePositionAdjustment:UIOffsetMake(5.0f, 0.0f) forBarMetrics:UIBarMetricsDefault];
    [mBackBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"MuseoSans-500" size:11.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
    [mSignupBtn setBackgroundImage:[UIImage imageNamed:@"navbaritem_orange.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [mSignupBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"MuseoSans-500" size:11.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
    
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            return 2;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TRTextFieldCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TRTextFieldCell"];
    if (!cell)
        cell = [[NSBundle mainBundle] loadNibNamed:@"TRTextFieldCell" owner:self options:nil][0];

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [cell setCapType:TRTableViewCellCapTypeTop];
                    [cell.textField setPlaceholder:@"First Name"];
                    [cell.textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
                    break;
                case 1:
                    [cell setCapType:TRTableViewCellCapTypeNone];
                    [cell.textField setPlaceholder:@"Last Name"];
                    [cell.textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
                    break;
                case 2:
                    [cell setCapType:TRTableViewCellCapTypeBot];
                    [cell.textField setPlaceholder:@"Phone Number"];
                    [cell.textField setKeyboardType:UIKeyboardTypePhonePad];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [cell setCapType:TRTableViewCellCapTypeTop];
                    [cell.textField setPlaceholder:@"Password"];
                    [cell.textField setSecureTextEntry:YES];
                    break;
                case 1:
                    [cell setCapType:TRTableViewCellCapTypeBot];
                    [cell.textField setPlaceholder:@"Confirm Password"];
                    [cell.textField setSecureTextEntry:YES];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Profile";
            break;
        case 1:
            return @"Account";
            break;
        default:
            break;
    }
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 6, tableView.bounds.size.width-80, 20.0)];
    tableView.sectionHeaderHeight = headerView.frame.size.height;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width-40, 18)];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.font = [UIFont boldSystemFontOfSize:16.0];
    label.shadowOffset = CGSizeMake(0, 1);
    label.shadowColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:0.298 green:0.2980 blue:0.2980 alpha:1.000];

    label.center = headerView.center;

    [headerView addSubview:label];

    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, tableView.bounds.size.width, tableView.sectionFooterHeight)];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width-40, 55)];
    label.text = [self tableView:tableView titleForFooterInSection:section];
    label.font = [UIFont systemFontOfSize:13.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.shadowOffset = CGSizeMake(0, 1);
    label.shadowColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithWhite:0.4f alpha:1.0];
    label.numberOfLines = 3;

    label.center = footerView.center;

    [footerView addSubview:label];
    return footerView;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return @"Your phone number will always remain private. By clicking Sign Up you are indicating that you have read and agree to the Terms of Service";
    } else {
        return nil;
    }

}

- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
