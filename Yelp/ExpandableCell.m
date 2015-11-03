//
//  ExpandableCell.m
//  Yelp
//
//  Created by  Minett on 11/2/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "ExpandableCell.h"

NSString *const kExpandCellId = @"ExpandCellId";

@interface ExpandableCell()

@end

@implementation ExpandableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
