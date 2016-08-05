//
//  OHExampleListTableViewController.m
//  Ohana
//
//  Copyright (c) 2016 Uber Technologies, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "OHExampleListTableViewController.h"

#import "OHBasicContactPickerTableViewController.h"
#import "OHPhoneNumberPickerTableViewController.h"
#import "OHContactSelectionTableViewController.h"
#import "OHFuzzySearchTableViewController.h"

#import "OhanaExample-Swift.h"

typedef NS_ENUM(NSInteger, OhanaExamples) {
    OhanaExamplesBasicContactPicker,
    OhanaExamplesBasicContactPhotosPicker,
    OhanaExamplesPhoneNumberPicker,
    OhanaExamplesContactSelection,
    OhanaExamplesFuzzySearch,
    OhanaExamplesPhoneOrEmailPicker,
    OhanaExamplesStatistics,
    OhanaExamplesSMSPicker,
    OhanaExamplesMaximumSelectedCountPicker,
};
const NSInteger OhanaExamplesCount = 9;

@interface OHExampleListTableViewController ()

@end

@implementation OHExampleListTableViewController

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        [self.navigationItem setTitle:@"Ohana Examples"];

        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ExampleCell"];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return OhanaExamplesCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExampleCell" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case OhanaExamplesBasicContactPicker:
            cell.textLabel.text = @"Basic Contact Picker";
            break;
        case OhanaExamplesBasicContactPhotosPicker:
            cell.textLabel.text = @"Basic Contact Photos Picker";
            break;
        case OhanaExamplesPhoneNumberPicker:
            cell.textLabel.text = @"Phone Number Picker";
            break;
        case OhanaExamplesContactSelection:
            cell.textLabel.text = @"Contact Selection";
            break;
        case OhanaExamplesFuzzySearch:
            cell.textLabel.text = @"Fuzzy Search";
            break;
        case OhanaExamplesPhoneOrEmailPicker:
            cell.textLabel.text = @"Phone or Email Picker";
            break;
        case OhanaExamplesStatistics:
            cell.textLabel.text = @"Statistics";
            break;
        case OhanaExamplesSMSPicker:
            cell.textLabel.text = @"SMS Contact Picker";
            break;
        case OhanaExamplesMaximumSelectedCountPicker:
            cell.textLabel.text = @"Maximum Selected Count Picker";
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case OhanaExamplesBasicContactPicker: {
            OHBasicContactPickerTableViewController *basicContactPicker = [[OHBasicContactPickerTableViewController alloc] init];
            [self.navigationController pushViewController:basicContactPicker animated:YES];
        } break;
        case OhanaExamplesBasicContactPhotosPicker: {
            OHBasicContactPhotosPicker *photosPicker = [[OHBasicContactPhotosPicker alloc] init];
            [self.navigationController pushViewController:photosPicker animated:YES];
        } break;
        case OhanaExamplesPhoneNumberPicker: {
            OHPhoneNumberPickerTableViewController *phoneNumberPicker = [[OHPhoneNumberPickerTableViewController alloc] init];
            [self.navigationController pushViewController:phoneNumberPicker animated:YES];
        } break;
        case OhanaExamplesContactSelection: {
            OHContactSelectionTableViewController *selectionPicker = [[OHContactSelectionTableViewController alloc] init];
            [self.navigationController pushViewController:selectionPicker animated:YES];
        } break;
        case OhanaExamplesFuzzySearch: {
            OHFuzzySearchTableViewController *fuzzySearchPicker = [[OHFuzzySearchTableViewController alloc] init];
            [self.navigationController pushViewController:fuzzySearchPicker animated:YES];
        } break;
        case OhanaExamplesPhoneOrEmailPicker: {
            OHPhoneOrEmailPicker *phoneEmailPicker = [[OHPhoneOrEmailPicker alloc] init];
            [self.navigationController pushViewController:phoneEmailPicker animated:YES];
        } break;
        case OhanaExamplesStatistics: {
            OHStatisticsExample *statisticsExample = [[OHStatisticsExample alloc] init];
            [statisticsExample generateStatistics:self];
        } break;
        case OhanaExamplesSMSPicker: {
            OHSMSPicker *smsPicker = [[OHSMSPicker alloc] init];
            [self.navigationController pushViewController:smsPicker animated:YES];
        } break;
        case OhanaExamplesMaximumSelectedCountPicker: {
            OHMaximumSelectedCountPicker *maxPicker = [[OHMaximumSelectedCountPicker alloc] init];
            [self.navigationController pushViewController:maxPicker animated:YES];
        } break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
