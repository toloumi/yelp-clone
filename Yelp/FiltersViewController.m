//
//  FiltersViewController.m
//  Yelp
//
//  Created by  Minett on 11/1/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "FiltersSwitchCell.h"
#import "ExpandableCell.h"
#import "FiltersSelectCell.h"

NSString *const kFiltersKey = @"filtersKey";
NSString *const kSortKey = @"sortKey";
NSString *const kRadiusKey = @"radiusKey";
NSString *const kDealsKey = @"dealsKey";

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, FiltersSwitchCellDelegate>
@property (nonatomic, readonly) NSArray *sectionNames;
@property (nonatomic, readonly) NSArray *sortByNames;
@property (nonatomic, readonly) NSArray *distanceValues;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) NSMutableDictionary *filters;
@property (nonatomic, copy) NSArray *categories;
@property (nonatomic, strong) NSMutableSet *selectedFilters;
@property (nonatomic, strong) NSNumber *selectedDistance;
@property (nonatomic, assign) NSInteger selectedSort;
@property (nonatomic, assign) BOOL offeringDeals;
@property (nonatomic, assign) BOOL expandSortBy;
@property (nonatomic, assign) BOOL expandDistance;
@property (nonatomic, assign) BOOL expandFilters;

- (void)initCategories;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _offeringDeals = NO;
        _expandSortBy = NO;
        _expandDistance = NO;
        
        //YelpSortModeBestMatched = 0,
        //YelpSortModeDistance = 1,
        //YelpSortModeHighestRated = 2
        _sectionNames = @[@"Deals", @"Distance", @"Sort By", @"Category Filters"];
        _sortByNames = @[@"Best Matched", @"Distance", @"Highest Rated"];
        _selectedSort = 0;
        //_selectedDistance = nil;
        _distanceValues = @[@(0.5), @(1), @(5), @(25)];
        _selectedFilters = [NSMutableSet set];
        [self initCategories];
        
        self.title = @"Filters";
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"FiltersSwitchCell" bundle:nil] forCellReuseIdentifier:kSwitchCellId];
    [self.tableView registerNib:[UINib nibWithNibName:@"ExpandableCell" bundle:nil] forCellReuseIdentifier:kExpandCellId];
    [self.tableView registerNib:[UINib nibWithNibName:@"FiltersSelectCell" bundle:nil] forCellReuseIdentifier:kSelectCellId];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onFiltersCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(onFiltersApplyButton)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDictionary *)filters {
    NSMutableArray *filterNames = [NSMutableArray array];
    if (self.selectedFilters.count > 0) {
        for (NSDictionary *filter in self.selectedFilters) {
            [filterNames addObject:filter[@"code"]];
        }
    }
    
    return @{kFiltersKey:filterNames, kDealsKey:[NSNumber numberWithBool:self.offeringDeals], kSortKey:@(self.selectedSort), kRadiusKey:self.distanceValues[[self.selectedDistance intValue]]};
}

- (void)onFiltersCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onFiltersApplyButton {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FiltersSwitchCell *cell;
        cell = [self.tableView dequeueReusableCellWithIdentifier:kSwitchCellId];
        cell.filtersLabel.text = @"Locations Offering Deals";
        cell.isDealSwitch = YES;
        cell.switchOn = self.offeringDeals;
        cell.delegate = self;
        return cell;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            ExpandableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kExpandCellId];
            NSString *distanceString = self.selectedDistance ? [NSString stringWithFormat:@"%@ mi", self.distanceValues[[self.selectedDistance intValue]]] : @"Auto";
            cell.titleLabel.text = [NSString stringWithFormat:@"Distance by radius (%@)", distanceString];
            return cell;
        }
        
        FiltersSelectCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSelectCellId];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ mi", self.distanceValues[indexPath.row-1]];
        return cell;
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            ExpandableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kExpandCellId];
            cell.titleLabel.text = [NSString stringWithFormat:@"Sort By (%@)", self.sortByNames[self.selectedSort]];
            return cell;
        }
        
        FiltersSelectCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSelectCellId];
        cell.titleLabel.text = self.sortByNames[indexPath.row -1];
        return cell;
    } else {
        if ((indexPath.row == 4 && !self.expandFilters)) {
            ExpandableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kExpandCellId];
            cell.titleLabel.text = @"Show All";
            return cell;
        } else if (indexPath.row == self.categories.count && self.expandFilters) {
            ExpandableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kExpandCellId];
            cell.titleLabel.text = @"Collapse All";
            return cell;
        }
        
        FiltersSwitchCell *cell;
        cell = [self.tableView dequeueReusableCellWithIdentifier:kSwitchCellId];
        cell.filtersLabel.text = self.categories[indexPath.row][@"name"];
        cell.switchOn = [self.selectedFilters containsObject:self.categories[indexPath.row]];
        cell.delegate = self;
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.expandDistance ? 5 : 1;
    } else if (section == 2) {
        return self.expandSortBy ? 4 : 1;
    } else {
        return self.expandFilters ? self.categories.count + 1 : 5;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionNames[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1:
            if (self.expandDistance) {
                NSNumber *selectedDistance;
                if ([@[@(0), @(1), @(2), @(3)] containsObject:@(indexPath.row - 1)]) {
                    selectedDistance = @(indexPath.row - 1);
                }
                self.selectedDistance = selectedDistance;
            }
            
            self.expandDistance = !self.expandDistance;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case 2:
            if (self.expandSortBy) {
                NSInteger selectedSort = 0;
                if ([@[@(0), @(1), @(2)] containsObject:@(indexPath.row - 1)]) {
                    selectedSort = indexPath.row - 1;
                }
                self.selectedSort = selectedSort;
            }

            self.expandSortBy = !self.expandSortBy;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case 3:
            self.expandFilters = !self.expandFilters;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

#pragma mark - SwitchCell delegate methods
- (void)filterSwitchCell:(FiltersSwitchCell *)switchCell didChangeValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:switchCell];
    
    switch (indexPath.section) {
        case 0:
            self.offeringDeals = value;
            break;
            
        case 3:
            if (value) {
                [self.selectedFilters addObject:self.categories[indexPath.row]];
            } else {
                [self.selectedFilters removeObject:self.categories[indexPath.row]];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - Filter Categories

- (void)initCategories {
    self.categories = @[@{@"name": @"Afghan", @"code": @"afghani"},
                        @{@"name": @"African", @"code": @"african"},
                        @{@"name": @"American, New", @"code": @"newamerican"},
                        @{@"name": @"American, Traditional", @"code": @"tradamerican"},
                        @{@"name": @"Arabian", @"code": @"arabian"},
                        @{@"name": @"Argentine", @"code": @"argentine"},
                        @{@"name": @"Armenian", @"code": @"armenian"},
                        @{@"name": @"Asian Fusion", @"code": @"asianfusion"},
                        @{@"name": @"Asturian", @"code": @"asturian"},
                        @{@"name": @"Australian", @"code": @"australian"},
                        @{@"name": @"Austrian", @"code": @"austrian"},
                        @{@"name": @"Baguettes", @"code": @"baguettes"},
                        @{@"name": @"Bangladeshi", @"code": @"bangladeshi"},
                        @{@"name": @"Barbeque", @"code": @"bbq"},
                        @{@"name": @"Basque", @"code": @"basque"},
                        @{@"name": @"Bavarian", @"code": @"bavarian"},
                        @{@"name": @"Beer Garden", @"code": @"beergarden"},
                        @{@"name": @"Beer Hall", @"code": @"beerhall"},
                        @{@"name": @"Beisl", @"code": @"beisl"},
                        @{@"name": @"Belgian", @"code": @"belgian"},
                        @{@"name": @"Bistros", @"code": @"bistros"},
                        @{@"name": @"Black Sea", @"code": @"blacksea"},
                        @{@"name": @"Brasseries", @"code": @"brasseries"},
                        @{@"name": @"Brazilian", @"code": @"brazilian"},
                        @{@"name": @"Breakfast & Brunch", @"code": @"breakfast_brunch"},
                        @{@"name": @"British", @"code": @"british"},
                        @{@"name": @"Buffets", @"code": @"buffets"},
                        @{@"name": @"Bulgarian", @"code": @"bulgarian"},
                        @{@"name": @"Burgers", @"code": @"burgers"},
                        @{@"name": @"Burmese", @"code": @"burmese"},
                        @{@"name": @"Cafes", @"code": @"cafes"},
                        @{@"name": @"Cafeteria", @"code": @"cafeteria"},
                        @{@"name": @"Cajun/Creole", @"code": @"cajun"},
                        @{@"name": @"Cambodian", @"code": @"cambodian"},
                        @{@"name": @"Canadian", @"code": @"New)"},
                        @{@"name": @"Canteen", @"code": @"canteen"},
                        @{@"name": @"Caribbean", @"code": @"caribbean"},
                        @{@"name": @"Catalan", @"code": @"catalan"},
                        @{@"name": @"Chech", @"code": @"chech"},
                        @{@"name": @"Cheesesteaks", @"code": @"cheesesteaks"},
                        @{@"name": @"Chicken Shop", @"code": @"chickenshop"},
                        @{@"name": @"Chicken Wings", @"code": @"chicken_wings"},
                        @{@"name": @"Chilean", @"code": @"chilean"},
                        @{@"name": @"Chinese", @"code": @"chinese"},
                        @{@"name": @"Comfort Food", @"code": @"comfortfood"},
                        @{@"name": @"Corsican", @"code": @"corsican"},
                        @{@"name": @"Creperies", @"code": @"creperies"},
                        @{@"name": @"Cuban", @"code": @"cuban"},
                        @{@"name": @"Curry Sausage", @"code": @"currysausage"},
                        @{@"name": @"Cypriot", @"code": @"cypriot"},
                        @{@"name": @"Czech", @"code": @"czech"},
                        @{@"name": @"Czech/Slovakian", @"code": @"czechslovakian"},
                        @{@"name": @"Danish", @"code": @"danish"},
                        @{@"name": @"Delis", @"code": @"delis"},
                        @{@"name": @"Diners", @"code": @"diners"},
                        @{@"name": @"Dumplings", @"code": @"dumplings"},
                        @{@"name": @"Eastern European", @"code": @"eastern_european"},
                        @{@"name": @"Ethiopian", @"code": @"ethiopian"},
                        @{@"name": @"Fast Food", @"code": @"hotdogs"},
                        @{@"name": @"Filipino", @"code": @"filipino"},
                        @{@"name": @"Fish & Chips", @"code": @"fishnchips"},
                        @{@"name": @"Fondue", @"code": @"fondue"},
                        @{@"name": @"Food Court", @"code": @"food_court"},
                        @{@"name": @"Food Stands", @"code": @"foodstands"},
                        @{@"name": @"French", @"code": @"french"},
                        @{@"name": @"French Southwest", @"code": @"sud_ouest"},
                        @{@"name": @"Galician", @"code": @"galician"},
                        @{@"name": @"Gastropubs", @"code": @"gastropubs"},
                        @{@"name": @"Georgian", @"code": @"georgian"},
                        @{@"name": @"German", @"code": @"german"},
                        @{@"name": @"Giblets", @"code": @"giblets"},
                        @{@"name": @"Gluten-Free", @"code": @"gluten_free"},
                        @{@"name": @"Greek", @"code": @"greek"},
                        @{@"name": @"Halal", @"code": @"halal"},
                        @{@"name": @"Hawaiian", @"code": @"hawaiian"},
                        @{@"name": @"Heuriger", @"code": @"heuriger"},
                        @{@"name": @"Himalayan/Nepalese", @"code": @"himalayan"},
                        @{@"name": @"Hong Kong Style Cafe", @"code": @"hkcafe"},
                        @{@"name": @"Hot Dogs", @"code": @"hotdog"},
                        @{@"name": @"Hot Pot", @"code": @"hotpot"},
                        @{@"name": @"Hungarian", @"code": @"hungarian"},
                        @{@"name": @"Iberian", @"code": @"iberian"},
                        @{@"name": @"Indian", @"code": @"indpak"},
                        @{@"name": @"Indonesian", @"code": @"indonesian"},
                        @{@"name": @"International", @"code": @"international"},
                        @{@"name": @"Irish", @"code": @"irish"},
                        @{@"name": @"Island Pub", @"code": @"island_pub"},
                        @{@"name": @"Israeli", @"code": @"israeli"},
                        @{@"name": @"Italian", @"code": @"italian"},
                        @{@"name": @"Japanese", @"code": @"japanese"},
                        @{@"name": @"Jewish", @"code": @"jewish"},
                        @{@"name": @"Kebab", @"code": @"kebab"},
                        @{@"name": @"Korean", @"code": @"korean"},
                        @{@"name": @"Kosher", @"code": @"kosher"},
                        @{@"name": @"Kurdish", @"code": @"kurdish"},
                        @{@"name": @"Laos", @"code": @"laos"},
                        @{@"name": @"Laotian", @"code": @"laotian"},
                        @{@"name": @"Latin American", @"code": @"latin"},
                        @{@"name": @"Live/Raw Food", @"code": @"raw_food"},
                        @{@"name": @"Lyonnais", @"code": @"lyonnais"},
                        @{@"name": @"Malaysian", @"code": @"malaysian"},
                        @{@"name": @"Meatballs", @"code": @"meatballs"},
                        @{@"name": @"Mediterranean", @"code": @"mediterranean"},
                        @{@"name": @"Mexican", @"code": @"mexican"},
                        @{@"name": @"Middle Eastern", @"code": @"mideastern"},
                        @{@"name": @"Milk Bars", @"code": @"milkbars"},
                        @{@"name": @"Modern Australian", @"code": @"modern_australian"},
                        @{@"name": @"Modern European", @"code": @"modern_european"},
                        @{@"name": @"Mongolian", @"code": @"mongolian"},
                        @{@"name": @"Moroccan", @"code": @"moroccan"},
                        @{@"name": @"New Zealand", @"code": @"newzealand"},
                        @{@"name": @"Night Food", @"code": @"nightfood"},
                        @{@"name": @"Norcinerie", @"code": @"norcinerie"},
                        @{@"name": @"Open Sandwiches", @"code": @"opensandwiches"},
                        @{@"name": @"Oriental", @"code": @"oriental"},
                        @{@"name": @"Pakistani", @"code": @"pakistani"},
                        @{@"name": @"Parent Cafes", @"code": @"eltern_cafes"},
                        @{@"name": @"Parma", @"code": @"parma"},
                        @{@"name": @"Persian/Iranian", @"code": @"persian"},
                        @{@"name": @"Peruvian", @"code": @"peruvian"},
                        @{@"name": @"Pita", @"code": @"pita"},
                        @{@"name": @"Pizza", @"code": @"pizza"},
                        @{@"name": @"Polish", @"code": @"polish"},
                        @{@"name": @"Portuguese", @"code": @"portuguese"},
                        @{@"name": @"Potatoes", @"code": @"potatoes"},
                        @{@"name": @"Poutineries", @"code": @"poutineries"},
                        @{@"name": @"Pub Food", @"code": @"pubfood"},
                        @{@"name": @"Rice", @"code": @"riceshop"},
                        @{@"name": @"Romanian", @"code": @"romanian"},
                        @{@"name": @"Rotisserie Chicken", @"code": @"rotisserie_chicken"},
                        @{@"name": @"Rumanian", @"code": @"rumanian"},
                        @{@"name": @"Russian", @"code": @"russian"},
                        @{@"name": @"Salad", @"code": @"salad"},
                        @{@"name": @"Sandwiches", @"code": @"sandwiches"},
                        @{@"name": @"Scandinavian", @"code": @"scandinavian"},
                        @{@"name": @"Scottish", @"code": @"scottish"},
                        @{@"name": @"Seafood", @"code": @"seafood"},
                        @{@"name": @"Serbo Croatian", @"code": @"serbocroatian"},
                        @{@"name": @"Signature Cuisine", @"code": @"signature_cuisine"},
                        @{@"name": @"Singaporean", @"code": @"singaporean"},
                        @{@"name": @"Slovakian", @"code": @"slovakian"},
                        @{@"name": @"Soul Food", @"code": @"soulfood"},
                        @{@"name": @"Soup", @"code": @"soup"},
                        @{@"name": @"Southern", @"code": @"southern"},
                        @{@"name": @"Spanish", @"code": @"spanish"},
                        @{@"name": @"Steakhouses", @"code": @"steak"},
                        @{@"name": @"Sushi Bars", @"code": @"sushi"},
                        @{@"name": @"Swabian", @"code": @"swabian"},
                        @{@"name": @"Swedish", @"code": @"swedish"},
                        @{@"name": @"Swiss Food", @"code": @"swissfood"},
                        @{@"name": @"Tabernas", @"code": @"tabernas"},
                        @{@"name": @"Taiwanese", @"code": @"taiwanese"},
                        @{@"name": @"Tapas Bars", @"code": @"tapas"},
                        @{@"name": @"Tapas/Small Plates", @"code": @"tapasmallplates"},
                        @{@"name": @"Tex-Mex", @"code": @"tex-mex"},
                        @{@"name": @"Thai", @"code": @"thai"},
                        @{@"name": @"Traditional Norwegian", @"code": @"norwegian"},
                        @{@"name": @"Traditional Swedish", @"code": @"traditional_swedish"},
                        @{@"name": @"Trattorie", @"code": @"trattorie"},
                        @{@"name": @"Turkish", @"code": @"turkish"},
                        @{@"name": @"Ukrainian", @"code": @"ukrainian"},
                        @{@"name": @"Uzbek", @"code": @"uzbek"},
                        @{@"name": @"Vegan", @"code": @"vegan"},
                        @{@"name": @"Vegetarian", @"code": @"vegetarian"},
                        @{@"name": @"Venison", @"code": @"venison"},
                        @{@"name": @"Vietnamese", @"code": @"vietnamese"},
                        @{@"name": @"Wok", @"code": @"wok"},
                        @{@"name": @"Wraps", @"code": @"wraps"},
                        @{@"name": @"Yugoslav", @"code": @"yugoslav"}];
}

@end
