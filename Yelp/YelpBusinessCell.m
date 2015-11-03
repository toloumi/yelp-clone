//
//  YelpBusinessCell.m
//  Yelp
//
//  Created by  Minett on 10/30/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "YelpBusinessCell.h"
#import "UIImageView+AFNetworking.h"

NSString *const kCellId = @"YelpBusinessCell";

@interface YelpBusinessCell ()
@property (strong, nonatomic) IBOutlet UIImageView *businessImage;
@property (strong, nonatomic) IBOutlet UILabel *businessName;
@property (strong, nonatomic) IBOutlet UIImageView *reviewsImage;
@property (strong, nonatomic) IBOutlet UILabel *reviews;
@property (strong, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) IBOutlet UILabel *categories;
@property (strong, nonatomic) IBOutlet UILabel *distance;

@end

@implementation YelpBusinessCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.businessImage.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBusiness:(YelpBusiness *)business {
    _business = business;
    
    [self.businessImage setImageWithURL:self.business.imageUrl];
    [self.reviewsImage setImageWithURL:self.business.ratingImageUrl];
    self.businessName.text = self.business.name;
    self.reviews.text = [NSString stringWithFormat:@"%@ Reviews", self.business.reviewCount];
    self.address.text = self.business.address;
    self.categories.text = self.business.categories;
    self.distance.text = [NSString stringWithFormat:@"%@", self.business.distance];
}

@end
