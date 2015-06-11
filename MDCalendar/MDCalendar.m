//
//  MDCalendar.m
//
//
//  Copyright (c) 2014 Michael DiStefano
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "MDCalendar.h"
#import "MDBubbleView.h"
#import "MDTriangleView.h"
#import "MDCalendarHeaderView.h"
#import "MDCalendarFooterView.h"
#import "MDCalendarViewCell.h"

@interface MDCalendar () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIView *topLine;

@property (nonatomic, assign) NSDate *currentDate;
@property (nonatomic, strong) MDBubbleView *hintView;
@property (nonatomic, strong) MDTriangleView *triangleView;
@end

#define DAYS_IN_WEEK 7
#define MONTHS_IN_YEAR 12

// Default spacing
static CGFloat const kMDCalendarViewItemSpacing    = 0.f;
static CGFloat const kMDCalendarViewLineSpacing    = 1.f;
static CGFloat const kMDCalendarViewSectionSpacing = 10.f;

@implementation MDCalendar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setClipsToBounds:YES];

        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing  = kMDCalendarViewItemSpacing;
        layout.minimumLineSpacing       = kMDCalendarViewLineSpacing;
        self.layout = layout;

        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate   = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.allowsMultipleSelection = YES;
        _collectionView.scrollEnabled = NO;

        [_collectionView registerClass:[MDCalendarViewCell class] forCellWithReuseIdentifier:kMDCalendarViewCellIdentifier];
        [_collectionView registerClass:[MDCalendarHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMDCalendarHeaderViewIdentifier];
        [_collectionView registerClass:[MDCalendarFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kMDCalendarFooterViewIdentifier];

//        UIPanGestureRecognizer *what = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
//        [self addGestureRecognizer:what];

        // Default Configuration
        self.startDate      = _currentDate;
        self.selectedStartDate   = _startDate;
        self.selectedEndDate = [self.selectedStartDate dateByAddingDays:1];
        self.endDate        = [[_startDate dateByAddingMonths:3] lastDayOfMonth];

        self.dayFont        = [UIFont systemFontOfSize:17];
        self.weekdayFont    = [UIFont systemFontOfSize:12];

        self.cellBackgroundColor    = nil;
        self.highlightColor         = self.tintColor;
        self.indicatorColor         = [UIColor lightGrayColor];

        self.headerBackgroundColor  = nil;
        self.headerFont             = [UIFont systemFontOfSize:20];

        self.textColor          = [UIColor darkGrayColor];
        self.headerTextColor    = _textColor;
        self.weekdayTextColor   = _textColor;

        self.canSelectDaysBeforeStartDate = YES;

        _leftButton = [[UIButton alloc] init];
        [self.leftButton setTitle:@"<" forState:UIControlStateNormal];
        [self.leftButton setTitleColor:_textColor forState:UIControlStateNormal];
        [self.leftButton setBackgroundColor:[UIColor whiteColor]];
        [self.leftButton addTarget:self action:@selector(previousMonth) forControlEvents:UIControlEventTouchUpInside];

        _rightButton = [[UIButton alloc] init];
        [self.rightButton setTitle:@">" forState:UIControlStateNormal];
        [self.rightButton setTitleColor:_textColor forState:UIControlStateNormal];
        [self.rightButton setBackgroundColor:[UIColor whiteColor]];
        [self.rightButton addTarget:self action:@selector(nextMonth) forControlEvents:UIControlEventTouchUpInside];

        _topLine = [[UIView alloc] init];
        [self.topLine setBackgroundColor:[UIColor grayColor]];

        [self addSubview:self.collectionView];
        [self addSubview:self.leftButton];
        [self addSubview:self.rightButton];
        [self addSubview:self.topLine];

        [self setConstraints];
    }
    return self;
}

- (void)setConstraints{
    [self.collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *collectionViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                                      attribute:NSLayoutAttributeTop
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:self
                                                                                      attribute:NSLayoutAttributeTop
                                                                                     multiplier:1
                                                                                       constant:10];

    NSLayoutConstraint *collectionViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                                    attribute:NSLayoutAttributeLeft
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self
                                                                                    attribute:NSLayoutAttributeLeft
                                                                                   multiplier:1
                                                                                     constant:0];

    NSLayoutConstraint *collectionViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                                    attribute:NSLayoutAttributeRight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self
                                                                                    attribute:NSLayoutAttributeRight
                                                                                   multiplier:1
                                                                                     constant:0];

    NSLayoutConstraint *collectionViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                                    attribute:NSLayoutAttributeBottom
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self
                                                                                    attribute:NSLayoutAttributeBottom
                                                                                   multiplier:1
                                                                                     constant:0];
    [self addConstraints:@[collectionViewBottomConstraint, collectionViewTopConstraint, collectionViewLeftConstraint, collectionViewRightConstraint]];

    [self.leftButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *leftButtonLeftConstraint = [NSLayoutConstraint constraintWithItem:self.leftButton
                                                                                attribute:NSLayoutAttributeLeft
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeLeft
                                                                               multiplier:1
                                                                                 constant:10];

    NSLayoutConstraint *leftButtonTopConstraint = [NSLayoutConstraint constraintWithItem:self.leftButton
                                                                                attribute:NSLayoutAttributeTop
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.collectionView
                                                                                attribute:NSLayoutAttributeTop
                                                                               multiplier:1
                                                                                 constant:0];

    NSLayoutConstraint *leftButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:self.leftButton
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1
                                                                                  constant:60];

    NSLayoutConstraint *leftButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:self.leftButton
                                                                                 attribute:NSLayoutAttributeHeight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1
                                                                                  constant:30];
    [self addConstraints:@[leftButtonHeightConstraint, leftButtonLeftConstraint, leftButtonTopConstraint, leftButtonWidthConstraint]];

    [self.rightButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *rightButtonRightConstraint = [NSLayoutConstraint constraintWithItem:self.rightButton
                                                                                attribute:NSLayoutAttributeRight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self
                                                                                attribute:NSLayoutAttributeRight
                                                                               multiplier:1
                                                                                 constant:-10];

    NSLayoutConstraint *rightButtonTopConstraint = [NSLayoutConstraint constraintWithItem:self.rightButton
                                                                               attribute:NSLayoutAttributeTop
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.collectionView
                                                                               attribute:NSLayoutAttributeTop
                                                                              multiplier:1
                                                                                constant:0];

    NSLayoutConstraint *rightButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:self.rightButton
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                                multiplier:1
                                                                                  constant:60];

    NSLayoutConstraint *rightButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:self.rightButton
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:nil
                                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                                 multiplier:1
                                                                                   constant:30];
    [self addConstraints:@[rightButtonHeightConstraint, rightButtonRightConstraint, rightButtonTopConstraint, rightButtonWidthConstraint]];

    [self.topLine setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *topLineTopConstraint = [NSLayoutConstraint constraintWithItem:self.topLine
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1
                                                                             constant:0];
    NSLayoutConstraint *topLineLeftConstraint = [NSLayoutConstraint constraintWithItem:self.topLine
                                                                            attribute:NSLayoutAttributeLeft
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeLeft
                                                                           multiplier:1
                                                                             constant:0];

    NSLayoutConstraint *topLineRightConstraint = [NSLayoutConstraint constraintWithItem:self.topLine
                                                                            attribute:NSLayoutAttributeRight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeRight
                                                                           multiplier:1
                                                                             constant:0];
    NSLayoutConstraint *topLineHeightConstraint = [NSLayoutConstraint constraintWithItem:self.topLine
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1
                                                                             constant:.5];
    [self addConstraints:@[topLineHeightConstraint, topLineLeftConstraint, topLineRightConstraint, topLineTopConstraint]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    if(self.selectedStartDate){
//        NSIndexPath *indexPath = [self indexPathForDate:self.selectedStartDate];
//        [self scrollCalendarToTopOfSection:indexPath.section animated:NO];
//    }
}

#pragma mark - Custom Accessors

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _collectionView.contentInset = contentInset;
}

- (void)setItemSpacing:(CGFloat)itemSpacing {
    _layout.minimumInteritemSpacing = itemSpacing;
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    _layout.minimumLineSpacing = lineSpacing;
}

- (CGFloat)lineSpacing {
    return _layout.minimumLineSpacing;
}

- (void)setBorderHeight:(CGFloat)borderHeight {
    _borderHeight = borderHeight;
    if (borderHeight) {
        self.lineSpacing = 0.f;
    }
}

- (NSDate *)currentDate {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"MMM dd yyyy"];
//    NSDate *date = [NSDate date];
//    return [dateFormatter dateFromString:[dateFormatter stringFromDate:date]];
    return [NSDate date];
}

#pragma mark - Public Methods

- (void)scrollCalendarToDate:(NSDate *)date animated:(BOOL)animated {
    UICollectionView *collectionView = _collectionView;
    NSIndexPath *indexPath = [self indexPathForDate:date];
    NSSet *visibleIndexPaths = [NSSet setWithArray:[collectionView indexPathsForVisibleItems]];
    if (indexPath && [visibleIndexPaths count] && ![visibleIndexPaths containsObject:indexPath]) {
        [self scrollCalendarToTopOfSection:indexPath.section animated:animated];
    }
}

#pragma mark - Private Methods & Helper Functions

- (NSInteger)monthForSection:(NSInteger)section {
    NSDate *firstDayOfMonth = [[_startDate firstDayOfMonth] dateByAddingMonths:section];
    return [firstDayOfMonth month];
}

- (NSDate *)dateForFirstDayOfSection:(NSInteger)section {
    return [[_startDate firstDayOfMonth] dateByAddingMonths:section];
}

- (NSDate *)dateForLastDayOfSection:(NSInteger)section {
    NSDate *firstDayOfMonth = [self dateForFirstDayOfSection:section];
    return [firstDayOfMonth lastDayOfMonth];
}

- (NSInteger)offsetForSection:(NSInteger)section {
    NSDate *firstDayOfMonth = [self dateForFirstDayOfSection:section];
    return [firstDayOfMonth weekday] - 1;
}

- (NSInteger)remainderForSection:(NSInteger)section {
    NSDate *lastDayOfMonth = [self dateForLastDayOfSection:section];
    NSInteger weekday = [lastDayOfMonth weekday];
    return DAYS_IN_WEEK - weekday;
}

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath {
    NSDate *date = [_startDate dateByAddingMonths:indexPath.section];
    NSDateComponents *components = [date components];
    components.day = indexPath.item + 1;
    date = [NSDate dateFromComponents:components];

    NSInteger offset = [self offsetForSection:indexPath.section];
    if (offset) {
        date = [date dateByAddingDays:-offset];
    }

    return date;
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date {
    NSIndexPath *indexPath = nil;
    if (date) {
        NSDate *firstDayOfCalendar = [_startDate firstDayOfMonth];
        NSInteger section = [firstDayOfCalendar numberOfMonthsUntilEndDate:date];
        NSInteger dayOffset = [self offsetForSection:section];
        NSInteger dayIndex = [date day] + dayOffset - 1;
        indexPath = [NSIndexPath indexPathForItem:dayIndex inSection:section];
    }
    return indexPath;
}

- (CGRect)frameForHeaderForSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:section];
    UICollectionViewLayoutAttributes *attributes = [_collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect frameForFirstCell = attributes.frame;
    CGFloat headerHeight = [self collectionView:_collectionView layout:_layout referenceSizeForHeaderInSection:section].height;
    return CGRectOffset(frameForFirstCell, 0, -headerHeight);
}

- (void)scrollCalendarToTopOfSection:(NSInteger)section animated:(BOOL)animated {
    CGRect headerRect = [self frameForHeaderForSection:section];
    CGPoint topOfHeader = CGPointMake(0, headerRect.origin.y - _collectionView.contentInset.top);
    [_collectionView setContentOffset:topOfHeader animated:animated];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [_startDate numberOfMonthsUntilEndDate:_endDate] + 1;    // Adding 1 necessary to show month of end date
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDate *firstDayOfMonth = [self dateForFirstDayOfSection:section];
    NSInteger month = [firstDayOfMonth month];
    NSInteger year  = [firstDayOfMonth year];
    return [NSDate numberOfDaysInMonth:month forYear:year] + [self offsetForSection:section] + [self remainderForSection:section];
}

#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *date = [self dateForIndexPath:indexPath];

    MDCalendarViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMDCalendarViewCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = _cellBackgroundColor;
    cell.font = _dayFont;
    cell.textColor = [date isEqualToDateSansTime:[self currentDate]] ? _highlightColor : _textColor;
    cell.date = date;
    cell.highlightColor = _highlightColor;
    cell.borderHeight = _borderHeight;
    cell.borderColor = _borderColor;

    BOOL showIndicator = NO;
    if ([_delegate respondsToSelector:@selector(calendarView:shouldShowIndicatorForDate:)]) {
        showIndicator = [_delegate calendarView:self shouldShowIndicatorForDate:date];
    }

    NSInteger sectionMonth = [self monthForSection:indexPath.section];

    cell.userInteractionEnabled = [self collectionView:collectionView shouldSelectItemAtIndexPath:indexPath] ? YES : NO;

    // Disable non-selectable cells
    if (![self collectionView:collectionView shouldSelectItemAtIndexPath:indexPath]) {
        cell.textColor = [date isEqualToDateSansTime:[self currentDate]] ? cell.textColor : [cell.textColor colorWithAlphaComponent:0.2];
        cell.userInteractionEnabled = NO;

        // If the cell is outside the selectable range, and it is not today, tell the user
        // that it is an invalid date ("dimmed" is what Apple uses for disabled buttons).
        if (![date isEqualToDateSansTime:_selectedStartDate]) {
            cell.accessibilityLabel = [cell.accessibilityLabel stringByAppendingString:@", dimmed"];
        }
    }

    // Handle showing cells outside of current month
    cell.accessibilityElementsHidden = NO;
    if ([date month] != sectionMonth) {
        if (_showsDaysOutsideCurrentMonth) {
            cell.backgroundColor = [cell.backgroundColor colorWithAlphaComponent:0.2];
        } else {
            cell.label.text = @"";
            showIndicator = NO;
            cell.accessibilityElementsHidden = YES;
        }
        cell.userInteractionEnabled = NO;
        [cell setSelected:NO];
    } else if ((date && self.selectedStartDate && [date isEqualToDate:self.selectedStartDate]) || (date && self.selectedEndDate && [date isEqualToDate:self.selectedEndDate])) {
        // Handle cell selection
        [cell setSelected:YES];
        [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    } else if (date && self.selectedStartDate && self.selectedEndDate && [date isAfterDate:self.selectedStartDate] && [date isBeforeDate:self.selectedEndDate]){
        [cell setSelectedBetweenRange:YES];
        [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    } else {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        [cell setSelected:NO];
    }

    cell.indicatorColor = showIndicator ? _indicatorColor : [UIColor clearColor];

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    UICollectionReusableView *view;

    if (kind == UICollectionElementKindSectionHeader) {
        MDCalendarHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMDCalendarHeaderViewIdentifier forIndexPath:indexPath];

        headerView.backgroundColor = _headerBackgroundColor;
        headerView.font = _headerFont;
        headerView.weekdayFont = _weekdayFont;
        headerView.textColor = _headerTextColor;
        headerView.weekdayTextColor = _weekdayTextColor;

        NSDate *date = [self dateForFirstDayOfSection:indexPath.section];
        headerView.shouldShowYear = [date year] != [_startDate year];
        headerView.firstDayOfMonth = date;

        view = headerView;
    } else if (kind == UICollectionElementKindSectionFooter) {
        MDCalendarFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kMDCalendarFooterViewIdentifier forIndexPath:indexPath];
        footerView.borderHeight = _showsBottomSectionBorder ? _borderHeight : 0.f;
        footerView.borderColor  = _borderColor;
        view = footerView;
    }

    return view;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *date = [self dateForIndexPath:indexPath];
    if(self.selectedStartDate && self.selectedEndDate){
        self.selectedStartDate = date;
        self.selectedEndDate = nil;
    } else if(self.selectedStartDate){
        if([date isBeforeDate:self.selectedStartDate]){
            self.selectedStartDate = date;
        } else {
            self.selectedEndDate = date;
        }
    } else {
        self.selectedStartDate = date;
        self.selectedEndDate = nil;
    }
    [self.collectionView reloadData];
    [self showHintView:indexPath];

    if ([_delegate respondsToSelector:@selector(calendarView:didSelectStartDate:endDate:)]) {
        [_delegate calendarView:self didSelectStartDate:self.selectedStartDate endDate:self.selectedEndDate];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self collectionView:collectionView didSelectItemAtIndexPath:indexPath];
}

//- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
//    return NO;
//}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *date = [self dateForIndexPath:indexPath];

    if ([date isBeforeDate:_startDate] && !_canSelectDaysBeforeStartDate) {
        return NO;
    }

    if ([_delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)]) {
        return [_delegate calendarView:self shouldSelectDate:date];
    }

    return YES;
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth = [self cellWidth];
    CGFloat cellHeight = cellWidth;
    return CGSizeMake(cellWidth, cellHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGFloat boundsWidth = collectionView.bounds.size.width;
    return CGSizeMake(boundsWidth, [MDCalendarHeaderView preferredHeightWithMonthLabelFont:_headerFont andWeekdayFont:_weekdayFont]);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(CGRectGetWidth(self.bounds), kMDCalendarViewSectionSpacing);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat boundsWidth = collectionView.bounds.size.width;
    CGFloat remainingPoints = boundsWidth - ([self cellWidth] * DAYS_IN_WEEK);
    return UIEdgeInsetsMake(0, remainingPoints / 2, 0, remainingPoints / 2);
}

// Helpers

- (CGFloat)cellWidth {
    CGFloat boundsWidth = _collectionView.bounds.size.width;
    return (CGFloat) (floor(boundsWidth / DAYS_IN_WEEK) - kMDCalendarViewItemSpacing);
}

- (void)panAction:(UIPanGestureRecognizer *)pan{
    CGPoint point = [pan locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    NSDate *date = [self dateForIndexPath:indexPath];
    if(!self.selectedStartDate || [date isAfterDate:self.selectedStartDate]){
        self.selectedEndDate = date;
        NSInteger days = [self.selectedStartDate numberOfDaysUntilEndDate:self.selectedEndDate];
        if([self collectionView:self.collectionView shouldSelectItemAtIndexPath:indexPath]){
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
        for(int i = 1; i <= days; i++){
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForItem:indexPath.item - i inSection:indexPath.section];
            if([self collectionView:self.collectionView shouldSelectItemAtIndexPath:indexPath1]){
                [self.collectionView selectItemAtIndexPath:indexPath1 animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            }
        }
    }
    NSLog(@"indexPath: %@", indexPath);
}

- (void)nextMonth{
    NSIndexPath *indexPath = [self.collectionView indexPathsForVisibleItems][0];
    [self scrollCalendarToTopOfSection:indexPath.section + 1 animated:YES];
}

- (void)previousMonth{
    NSIndexPath *indexPath = [self.collectionView indexPathsForVisibleItems][0];
    if(indexPath.section > 0){
        [self scrollCalendarToTopOfSection:indexPath.section - 1 animated:YES];
    }
}

-(void)showHintView:(NSIndexPath *)indexPath{
    if(self.hintLabelTopTextBlock || self.hintLabelBottomTextBlock){
        NSDate *date = [self dateForIndexPath:indexPath];
        UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
        CGPoint viewCenterPoint = [self.collectionView convertPoint:attributes.center toView:self];
        CGPoint viewOriginPoint = [self.collectionView convertPoint:attributes.frame.origin toView:self];
        if(self.triangleView){
            [self.triangleView removeFromSuperview];
        } else {
            self.triangleView = [[MDTriangleView alloc] initWithColor:[UIColor blackColor]];
            [self.triangleView setTranslatesAutoresizingMaskIntoConstraints:NO];
        }
        if(self.hintView){
            [self.hintView removeFromSuperview];
        } else {
            self.hintView = [[MDBubbleView alloc] init];
            [self.hintView setTranslatesAutoresizingMaskIntoConstraints:NO];
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHintView)];
            [self.hintView addGestureRecognizer:tapGestureRecognizer];
        }

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM d yyyy"];

        NSString *topHintText = [dateFormatter stringFromDate:date];
        NSString *bottomHintText = nil;
        if(self.hintLabelTopTextBlock){
            topHintText = self.hintLabelTopTextBlock(self.selectedStartDate, self.selectedEndDate);
        }
        if(self.hintLabelBottomTextBlock){
            bottomHintText = self.hintLabelBottomTextBlock(self.selectedStartDate, self.selectedEndDate);
        }
        [self.hintView.topLabel setText:topHintText];
        [self.hintView.bottomLabel setText:bottomHintText];

        [self addSubview:self.triangleView];
        [self addSubview:self.hintView];
        NSLayoutConstraint *triangleViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.triangleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeLeft multiplier:1 constant:viewCenterPoint.x];
        NSLayoutConstraint *triangleViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.triangleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:10];
        NSLayoutConstraint *triangleViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.triangleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:20];
        NSLayoutConstraint *triangleViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.triangleView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeTop multiplier:1 constant:viewOriginPoint.y - 10];

        NSLayoutConstraint *hintViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.hintView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.collectionView attribute:NSLayoutAttributeLeft multiplier:1 constant:viewCenterPoint.x];
        NSLayoutConstraint *hintViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.hintView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:5];
        NSLayoutConstraint *hintViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.hintView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:-5];
        NSLayoutConstraint *hintViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.hintView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:45];
        NSLayoutConstraint *hintViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.hintView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.triangleView attribute:NSLayoutAttributeTop multiplier:1 constant:1];
        [hintViewCenterXConstraint setPriority:UILayoutPriorityDefaultHigh];

        [self addConstraints:@[triangleViewBottomConstraint, triangleViewCenterXConstraint, triangleViewWidthConstraint, triangleViewHeightConstraint]];
        [self addConstraints:@[hintViewHeightConstraint, hintViewBottomConstraint, hintViewCenterXConstraint, hintViewLeftConstraint, hintViewRightConstraint]];
        [self layoutIfNeeded];
    }
}

-(void)hideHintView{
    [self.hintView removeFromSuperview];
    [self.triangleView removeFromSuperview];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self hideHintView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if(self.selectedEndDate){
        NSIndexPath *indexPath = [self indexPathForDate:self.selectedEndDate];
        [self showHintView:indexPath];
    } else if (self.selectedStartDate){
        NSIndexPath *indexPath = [self indexPathForDate:self.selectedStartDate];
        [self showHintView:indexPath];
    }
}

-(void)refreshView{
    [self.collectionView reloadData];
}
@end
