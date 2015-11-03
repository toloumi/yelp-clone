//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpBusiness.h"
#import "YelpBusinessCell.h"
#import "FiltersViewController.h"

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FiltersViewControllerDelegate>
@property (nonatomic, strong) NSArray *yelpBusinesses;
@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"YelpBusinessCell" bundle:nil] forCellReuseIdentifier:kCellId];
    self.tableView.estimatedRowHeight = 166;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.title = @"Yelp";
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filters" style:UIBarButtonItemStylePlain target:self action:@selector(onFiltersButton)];
    
    self.searchTerm = @"Restaurants";
    [self fetchBusinessesWithQuery:self.searchTerm filters:nil deals:nil sortMode:0 radius:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.yelpBusinesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YelpBusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    cell.business = self.yelpBusinesses[indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - FiltersViewControllerDelegat methods

- (void) filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    [self fetchBusinessesWithQuery:self.searchTerm filters:filters[kFiltersKey] deals:[filters[kDealsKey] boolValue] sortMode:filters[kSortKey] radius:filters[kRadiusKey]];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - SearchBar delegate methods

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.searchTerm = searchBar.text;
    [self fetchBusinessesWithQuery:self.searchTerm filters:nil deals:nil sortMode:0 radius:nil];
}

#pragma mark - Private

- (void)onFiltersButton {
    FiltersViewController *filtersViewController = [[FiltersViewController alloc] init];
    UINavigationController *filtersNavController = [[UINavigationController alloc] initWithRootViewController:filtersViewController];
    
    filtersViewController.delegate = self;
    
    [self presentViewController:filtersNavController animated:YES completion:nil];
}

- (void)fetchBusinessesWithQuery:(NSString *)query filters:(NSArray *)filters deals:(BOOL)deals sortMode:(NSNumber *)sortMode radius:(NSNumber *)radius {
    [YelpBusiness searchWithTerm:query
                        radius:radius
                        sortMode:(YelpSortMode)[sortMode intValue]
                      categories:filters
                           deals:deals
                      completion:^(NSArray *businesses, NSError *error) {
                          self.yelpBusinesses = businesses;
                          [self.tableView reloadData];
                      }];
}

@end
