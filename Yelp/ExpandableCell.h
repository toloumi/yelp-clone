//
//  ExpandableCell.h
//  Yelp
//
//  Created by  Minett on 11/2/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kExpandCellId;

@interface ExpandableCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end
