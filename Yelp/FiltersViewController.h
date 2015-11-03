//
//  FiltersViewController.h
//  Yelp
//
//  Created by  Minett on 11/1/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kFiltersKey;
extern NSString *const kSortKey;
extern NSString *const kRadiusKey;
extern NSString *const kDealsKey;

@class FiltersViewController;

@protocol FiltersViewControllerDelegate <NSObject>

- (void) filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters;

@end

@interface FiltersViewController : UIViewController
@property (nonatomic, weak) id<FiltersViewControllerDelegate> delegate;

@end
