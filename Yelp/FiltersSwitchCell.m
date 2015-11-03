//
//  FiltersSwitchCell.m
//  Yelp
//
//  Created by  Minett on 11/1/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "FiltersSwitchCell.h"

NSString *const kSwitchCellId = @"FiltersSwitchCell";

@interface FiltersSwitchCell ()
@property (strong, nonatomic) IBOutlet UISwitch *filterSwitch;
- (IBAction)switchValueChange:(id)sender;

@end

@implementation FiltersSwitchCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)switchValueChange:(id)sender {
    [self.delegate filterSwitchCell:self didChangeValue:self.filterSwitch.on];
}

- (void)setSwitchOn:(BOOL)switchOn {
    [self setSwitchOn:switchOn animated:NO];
}

- (void)setSwitchOn:(BOOL)switchOn animated:(BOOL)animated {
    _switchOn = switchOn;
    [self.filterSwitch setOn:self.switchOn animated:animated];
}

@end
