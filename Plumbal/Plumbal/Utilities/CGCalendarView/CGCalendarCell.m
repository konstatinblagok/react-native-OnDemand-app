//
//  CGCalendarCell.m
//  CapitalGene
//
//  Created by Chen Liang on 9/11/13.
//  Copyright (c) 2013 Chen Liang. All rights reserved.
//  See the LICENSE file distributed with this work.

#import "CGCalendarCell.h"
#import "UIImage+Additions.h"
#import "UIView+ViewHelpers.h"
#import "Swift_Bridging_Header.h"
#import <Plumbal-Swift.h>


@interface CGCalendarCell(){
    Languagehandler * objLanguagehandler;

}

@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UILabel *weekdayLabel;
@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic, strong) NSDateFormatter *dayFormatter;
@property (nonatomic, strong) NSDateFormatter *weekdayFormatter;
@property (nonatomic, strong) NSDateComponents *todayDateComponents;
@property (nonatomic, strong) UIView *todayDot;
@property (nonatomic) BOOL isToday;
@property (nonatomic, strong) Themes *themes;



@end

@implementation CGCalendarCell

- (id)initWithCalendar:(NSCalendar *)calendar reuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    _calendar = calendar;
    
    CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
    
    static CGSize shadowOffset;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shadowOffset = CGSizeMake(0.0f, onePixel);
    });
    self.shadowOffset = shadowOffset;
    self.columnSpacing = onePixel;
    self.textColor = [UIColor colorWithRed:0.47f green:0.5f blue:0.53f alpha:1.0f];
    self.backgroundColor = [UIColor clearColor];
    
    static dispatch_once_t imgToken;
    static UIImage *img;
    dispatch_once(&imgToken, ^{
        img = [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake([[self class]cellHeight]-4, [[self class]cellHeight]-4) andRoundSize:8.0];
    });
    self.selectedImageView = [[UIImageView alloc]initWithImage:img];
    
    self.selectedImageView.hidden=TRUE;
    
    return self;
    
    
}

+ (CGFloat)cellHeight;
{
    return 50.0;
}


- (void)createDayLabel
{
    self.dayLabel = [UILabel new];
    self.dayLabel.font = [UIFont fontWithName:@"Roboto" size:14.0f];
    self.dayLabel.textColor = [UIColor whiteColor];
    self.dayLabel.backgroundColor = [UIColor clearColor];
    
    [self.contentView insertSubview:self.dayLabel atIndex:0];
    
    self.weekdayLabel = [UILabel new];
    self.weekdayLabel.font = [UIFont fontWithName:@"Roboto" size:14.0f];
    self.weekdayLabel.backgroundColor = [UIColor clearColor];
    self.weekdayLabel.textColor = [UIColor whiteColor];
    [self.contentView insertSubview:self.weekdayLabel atIndex:1];
    
    self.selectedImageView.backgroundColor = [UIColor clearColor];
    [self.contentView insertSubview:self.selectedImageView atIndex:3];
    
    self.todayDot = [UIView new];
    self.todayDot.backgroundColor = [UIColor whiteColor];
    [self.contentView insertSubview:self.todayDot atIndex:2];
    //self.imageView.image = self.selectedImage;
    
    //self.backgroundView.backgroundColor =
}

- (UITableViewCellSelectionStyle)selectionStyle;
{
    return UITableViewCellSelectionStyleNone;
}

- (void)setIsToday:(BOOL)isToday
{
    if (isToday) {
        [self.todayDot setHidden:NO];
    }else{
        [self.todayDot setHidden:YES];
    }
    _isToday = isToday;
}

- (void)setDate: (NSDate*)date
{
    _date = date;
    if (!self.dayLabel) {
        [self createDayLabel];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDateComponents *components = [self.calendar components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [self.calendar dateFromComponents:components];
    components = [self.calendar components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    NSDate *otherDate = [self.calendar dateFromComponents:components];
#pragma clang diagnostic pop
    
    if([today isEqualToDate:otherDate]) {
        self.isToday = YES;
        
    }else{
        self.isToday = NO;
    }
    
    //self.dayButton.titleLabel.text = [self.dayFormatter stringFromDate:date];
    self.dayLabel.text = [[self.dayFormatter stringFromDate:date] uppercaseString];
    
    
    objLanguagehandler = [[Languagehandler alloc]init];
    if ([[[self.weekdayFormatter stringFromDate:date] uppercaseString]  isEqual: @"MON"]){
        
        
        self.weekdayLabel.text  = [objLanguagehandler VJLocalizedString:@"mon" comment:nil];
    }
    else if ([[[self.weekdayFormatter stringFromDate:date] uppercaseString]  isEqual: @"TUE"]){
        
        self.weekdayLabel.text  = [objLanguagehandler VJLocalizedString:@"tue" comment:nil];
    }
    else if ([[[self.weekdayFormatter stringFromDate:date] uppercaseString]  isEqual: @"WED"]){
        
        self.weekdayLabel.text  = [objLanguagehandler VJLocalizedString:@"wed" comment:nil];
    }
    else if ([[[self.weekdayFormatter stringFromDate:date] uppercaseString]  isEqual: @"THU"]){
        
        self.weekdayLabel.text  = [objLanguagehandler VJLocalizedString:@"thu" comment:nil];
    }
    else if ([[[self.weekdayFormatter stringFromDate:date] uppercaseString]  isEqual: @"FRI"]){
        
        self.weekdayLabel.text  = [objLanguagehandler VJLocalizedString:@"fri" comment:nil];
    }
    else if ([[[self.weekdayFormatter stringFromDate:date] uppercaseString]  isEqual: @"SAT"]){
        
        self.weekdayLabel.text  = [objLanguagehandler VJLocalizedString:@"sat" comment:nil];
    }
    else if ([[[self.weekdayFormatter stringFromDate:date] uppercaseString]  isEqual: @"SUN"]){
        
        self.weekdayLabel.text  = [objLanguagehandler VJLocalizedString:@"sun" comment:nil];
    }
    
    self.weekdayLabel.text = [[self.weekdayFormatter stringFromDate:date] uppercaseString];

    
    
    //[self.dayButton setTitle:@"LOL" forState:UIControlStateSelected];
    //self.dayButton.text = @"lol";
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    //if(self.selected == NO){
    /*
     if(highlighted){
     self.contentView.backgroundColor = [UIColor redColor];
     }else{
     self.contentView.backgroundColor = [UIColor clouds];
     }
     */
    //}else{
    //    self.contentView.backgroundColor = [UIColor orange];
    // }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
{
    //[super setSelected:selected];
    if (selected) {
        //self.contentView.backgroundColor = [UIColor clearColor];
        [self.selectedImageView setHidden:NO];
        _themes=[Themes new];
        self.dayLabel.textColor = [UIColor orangeColor];
        self.weekdayLabel.textColor = [UIColor orangeColor];;
        self.todayDot.backgroundColor = [UIColor orangeColor];;
        //[self.contentView.layer setBorderColor:[UIColor clearColor].cgColor];
        [self.contentView.layer setBorderWidth:0.0f];
    }else{
        //self.contentView.backgroundColor = [UIColor clearColor];
        [self.selectedImageView setHidden:YES];
        [self.contentView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.contentView.layer setBorderWidth:0.0f];
        self.dayLabel.textColor = [UIColor blackColor];
        
        self.weekdayLabel.textColor = [UIColor blackColor];
        self.todayDot.backgroundColor = [UIColor whiteColor];
    }
    
}
/*
 - (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect;
 {
 // for subclass to implement
 }
 */

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    [self.dayLabel sizeToFit];
    //self.dayLabel.frame = CGRectMake(0, 10, self.dayLabel.size.width, self.dayLabel.size.height);
    self.dayLabel.center = CGPointMake(self.contentView.center.x, self.contentView.center.y - 6 );
    
    [self.weekdayLabel sizeToFit];
    self.weekdayLabel.center = CGPointMake(self.contentView.center.x, self.contentView.center.y + 26);
    
    self.todayDot.frame = CGRectMake(0, self.dayLabel.origin.y + self.dayLabel.size.height, 4, 4);
    self.todayDot.center = CGPointMake(self.contentView.center.x, self.todayDot.center.y);
    
    self.selectedImageView.center = self.contentView.center;
    [self.contentView sendSubviewToBack:self.selectedImageView];
    //[self.contentView bringSubviewToFront:self.contentView];
}

- (NSDateFormatter *)dayFormatter
{
    if (!_dayFormatter) {
        _dayFormatter = [NSDateFormatter new];
        _dayFormatter.calendar = self.calendar;
        _dayFormatter.dateFormat = @"d";
    }
    return _dayFormatter;
}

- (NSDateFormatter *)weekdayFormatter
{
    if (!_weekdayFormatter) {
        _weekdayFormatter = [NSDateFormatter new];
        _weekdayFormatter.calendar = self.calendar;
        _weekdayFormatter.dateFormat = @"E";
    }
    
    return _weekdayFormatter;
}

- (NSDateComponents *)todayDateComponents;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    if (!_todayDateComponents) {
        self.todayDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
    }
    return _todayDateComponents;
#pragma clang diagnostic pop
}

- (void)prepareForReuse
{
    self.contentView.backgroundColor = [UIColor clearColor];
}
@end
