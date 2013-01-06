//
//  TRStreamSetupViewController.m
//  Stream
//
//  Created by Peter Tsoi on 12/19/12.
//  Copyright (c) 2012 TeamRocket. All rights reserved.
//

#import "TRStreamSetupViewController.h"

#import "TRPhotoStream.h"
#import "TRUser.h"

#import "TRAppDelegate.h"
#import "TRGraph.h"
#import "TRTableViewCell.h"
#import "TRTextFieldCell.h"

@interface TRStreamSetupViewController ()

@end

@implementation TRStreamSetupViewController

- (id)initWithStream:(TRPhotoStream*)stream {
    self = [self initWithNibName:@"TRStreamSetupViewController" bundle:nil];
    if (self) {
        mStream = stream;
        if (stream == nil) {
            mMode = kTRPhotoStreamSetupModeCreate;
        } else {
            mMode = kTRPhotoStreamSetupModeInvite;
            mParticipants = [mStream.participants mutableCopy];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [mCreateButton setBackgroundImage:[UIImage imageNamed:@"navbaritem_orange.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [mCreateButton setBackgroundImage:[UIImage imageNamed:@"navbaritem_orange_highlighted.png"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [mCreateButton setTarget:self];
    if (mMode == kTRPhotoStreamSetupModeInvite) {
        [mTitleItem setTitle:@"INVITE"];
        [mCreateButton setTitle:@"update"];
        [mCreateButton setAction:@selector(updateStreamTapped:)];
    } else {
        [mCreateButton setAction:@selector(createStreamTapped:)];
    }
    if (mParticipants == nil) {
        mParticipants = [[NSMutableArray alloc] init];
    }
    [mTableView registerNib:[UINib nibWithNibName:@"TRTextFieldCell" bundle:nil] forCellReuseIdentifier:@"TRTextFieldCell"];
}

- (IBAction)pressedCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pressedAddButton:(TRTokenField*)sender {
    [AppDelegate.graph registerForDelegateCallback:self];
    ABPeoplePickerNavigationController * ABPicker = [[ABPeoplePickerNavigationController alloc] init];
    ABPicker.peoplePickerDelegate = self;
    [self presentViewController:ABPicker animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return [mParticipants count] + 1;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TRTableViewCell * cell;
    int sectionRows = [tableView numberOfRowsInSection:[indexPath section]];
    if (indexPath.section == 1 && indexPath.row == sectionRows - 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AddCell"];
        if (!cell) {
            cell = [[TRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddCell"];
            [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:14.0f]];
            [cell.textLabel setTextColor:[UIColor lightGrayColor]];
            [cell.textLabel setText:@"Add a participant"];
            UIImageView * add = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_token.png"]];
            add.center = CGPointMake(cell.frame.size.width - add.frame.size.width, cell.center.y);
            [cell addSubview:add];
        }
    } else if (indexPath.section == 0) {
        if (mStreamNameField == nil) {
            mStreamNameField = [tableView dequeueReusableCellWithIdentifier:@"TRTextViewCell"];
            if (mStreamNameField == nil) {
                mStreamNameField = [[NSBundle mainBundle] loadNibNamed:@"TRTextFieldCell" owner:self options:nil][0];
                if (mMode == kTRPhotoStreamSetupModeCreate) {
                    mStreamNameField.textField.text = @"";
                    mStreamNameField.textField.placeholder = @"Name of stream";
                    mStreamNameField.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
                    [mStreamNameField.textField setEnabled:YES];
                } else {
                    mStreamNameField.textField.text = mStream.name;
                    [mStreamNameField.textField setEnabled:NO];
                }
            }
            [mStreamNameField setCapType:TRTableViewCellCapTypeTopBot];
            [mStreamNameField.textField setDelegate:self];
        }
        return mStreamNameField;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (!cell) {
            cell = [[TRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            if (!(mMode == kTRPhotoStreamSetupModeInvite && indexPath.row < [mStream.participants count])) {
                UIButton * remove = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 35.0, 35.0f)];
                [remove setBackgroundImage:[UIImage imageNamed:@"remove_token.png"] forState:UIControlStateNormal];
                remove.center = CGPointMake(cell.frame.size.width - remove.frame.size.width, cell.center.y);
                [remove addTarget:self action:@selector(removeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:remove];
            }
            [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f]];
        }
    }
    
    if (indexPath.row == 0 && sectionRows == 1) {
        [cell setCapType:TRTableViewCellCapTypeTopBot];
    } else if (indexPath.row == 0 && sectionRows > 1) {
        [cell setCapType:TRTableViewCellCapTypeTop];
    } else if (indexPath.row == sectionRows - 1) {
        [cell setCapType:TRTableViewCellCapTypeBot];
    } else {
        [cell setCapType:TRTableViewCellCapTypeNone];
    }
    if (indexPath.section == 1) {
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        if (indexPath.row == sectionRows - 1) {
            
        } else {
            TRUser * user = [mParticipants objectAtIndex:indexPath.row];
            [cell.textLabel setText:[NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName]];
        }
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
            return @"Participants";
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == [tableView numberOfRowsInSection:[indexPath section]] - 1) {
        [self pressedAddButton:nil];
    }
}

- (void)addParticipant:(TRUser*)newUser {
    if (mParticipants == nil) {
        mParticipants = [[NSMutableArray alloc] init];
    }
    BOOL userAdded = NO;
    for (TRUser * user in mParticipants) {
        userAdded = userAdded || [user.phone isEqualToString:newUser.phone];
    }
    if (!userAdded) {
        [mParticipants addObject:newUser];
    }
}

- (void)removeButtonTapped:(id)sender {
    NSIndexPath * index = [mTableView indexPathForCell:(UITableViewCell*)[sender superview]];
    [mParticipants removeObjectAtIndex:index.row];
    [mTableView reloadData];
}

- (void)createStreamTapped:(id)sender {
    NSMutableArray * participantPhones = [[NSMutableArray alloc] init];
    for (TRUser * user in mParticipants) {
        [participantPhones addObject:user.phone];
    }
    [AppDelegate.graph createStreamNamed:mStreamNameField.textField.text
                                forPhone:[[NSUserDefaults standardUserDefaults] objectForKey:@"user_phone"]
                        withParticipants:participantPhones];
    [self dismissViewControllerAnimated:YES completion:nil];
    [TestFlight passCheckpoint:@"Created Stream"];
}

- (void)updateStreamTapped:(id)sender {
    NSMutableArray * participantPhones = [[NSMutableArray alloc] init];
    for (TRUser * user in [mParticipants subarrayWithRange:NSMakeRange([mStream.participants count],
                                                                       [mParticipants count] - [mStream.participants count])]) {
        [participantPhones addObject:user.phone];
    }
    [AppDelegate.graph sendInviteUsers:participantPhones toStream:mStream.ID];
    [self dismissViewControllerAnimated:YES completion:nil];
    [TestFlight passCheckpoint:@"Updated Stream Info"];
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
        [AppDelegate.graph downloadUserStatus:phone];
        newUser = [[TRUser alloc] initWithPhone:phone
                                      firstName:first
                                       lastName:last];
        [AppDelegate.graph addUser:newUser];
        [self addParticipant:newUser];
    } else {
        
    }
    [mTableView reloadData];

    CFRelease(phones);
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TRGraphDelegate

- (void)graphFinishedUpdating {
    for (TRUser * participant in mParticipants) {
        TRUser * graphUser = [AppDelegate.graph getUserWithPhone:participant.phone];
        if (!graphUser) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't Invite User" message:[NSString stringWithFormat:@"%@ %@ is not currently participating in the Stream beta.", participant.firstName, participant.lastName] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
            [mParticipants removeObject:participant];
        }
    }
    [mTableView reloadData];
}


@end
