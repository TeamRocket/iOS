//
//  TRStreamSetupViewController.m
//  Stream
//
//  Created by Peter Tsoi on 12/19/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRStreamSetupViewController.h"

#import "TRUser.h"

#import "TRTextFieldCell.h"
#import "TRTokenField.h"

@interface TRStreamSetupViewController ()

@end

@implementation TRStreamSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [mCreateButton setBackgroundImage:[UIImage imageNamed:@"navbaritem_orange.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [mCreateButton setBackgroundImage:[UIImage imageNamed:@"navbaritem_orange_highlighted.png"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
}

- (IBAction)pressedCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pressedAddButton:(TRTokenField*)sender {
    ABPeoplePickerNavigationController * ABPicker = [[ABPeoplePickerNavigationController alloc] init];
    ABPicker.peoplePickerDelegate = self;
    [self presentViewController:ABPicker animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TRTextFieldCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TRTextFieldCell"];
    if (!cell)
        cell = [[NSBundle mainBundle] loadNibNamed:@"TRTextFieldCell" owner:self options:nil][0];

    [cell setCapType:TRTableViewCellCapTypeTopBot];

    if (indexPath.section == 1) {
        [cell.textField removeFromSuperview];
        mUsersField = [[TRTokenField alloc] initWithFrame:cell.textField.frame];
        cell.textField = (UITextField*)mUsersField;
        mUsersField.delegate = self;
        [cell addSubview:cell.textField];
    }
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return nil;
            break;
        case 1:
            return @"Recipients will be able to add photos to your stream via the app and through MMS. Standard text and data rates apply.";
            break;
        default:
            break;
    }
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Stream Details";
            break;
        case 1:
            return @"Receipients";
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


- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - ABPeoplePickerDelegate

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {

    NSString * first = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString * last = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString * phone;
    TRUser * newUser;

    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (phones == nil || ABMultiValueGetCount(phones) == 0) {
        CFArrayRef linkedContacts = ABPersonCopyArrayOfAllLinkedPeople(person);
        phones = ABMultiValueCreateMutable(kABPersonPhoneProperty);
        ABMultiValueRef linkedPhones;
        for (int i = 0; i < CFArrayGetCount(linkedContacts); i++) {
            ABRecordRef linkedContact = CFArrayGetValueAtIndex(linkedContacts, i);
            linkedPhones = ABRecordCopyValue(linkedContact, kABPersonPhoneProperty);
            if (linkedPhones != nil && ABMultiValueGetCount(linkedPhones) > 0) {
                for (int j = 0; j < ABMultiValueGetCount(linkedPhones); j++) {
                    ABMultiValueAddValueAndLabel(phones, ABMultiValueCopyValueAtIndex(linkedPhones, j), NULL, NULL);
                }
            }
            CFRelease(linkedPhones);
        }
        CFRelease(linkedContacts);
    }
    if (ABMultiValueGetCount(phones) > 0) {
        phone = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phones, 0);
        newUser = [[TRUser alloc] initWithPhone:phone
                                      firstName:first
                                       lastName:last];

        [mUsersField addTokenObject:newUser];
    } else {
        
    }

    CFRelease(phones);
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    return NO;
}

@end
