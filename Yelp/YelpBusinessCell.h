//
//  YelpBusinessCell.h
//  Yelp
//
//  Created by  Minett on 10/30/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YelpBusiness.h"

extern NSString *const kCellId;

@interface YelpBusinessCell : UITableViewCell
@property (nonatomic, strong) YelpBusiness *business;
@end
