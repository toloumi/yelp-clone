//
//  FiltersSwitchCell.h
//  Yelp
//
//  Created by  Minett on 11/1/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FiltersSwitchCell;

extern NSString *const kSwitchCellId;

@protocol FiltersSwitchCellDelegate <NSObject>

- (void)filterSwitchCell:(FiltersSwitchCell *)switchCell didChangeValue:(BOOL)value;

@end

@interface FiltersSwitchCell : UITableViewCell
@property (nonatomic, weak) id<FiltersSwitchCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *filtersLabel;
@property (nonatomic, assign) BOOL switchOn;
@property (nonatomic, assign) BOOL isDealSwitch;

- (void)setSwitchOn:(BOOL)switchOn animated:(BOOL)animated;

@end
