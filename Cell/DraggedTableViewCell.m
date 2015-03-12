//
//  TableViewCell.m
//  test_for_request
//
//  Created by LAN on 1/16/15.
//  Copyright (c) 2015 LAN. All rights reserved.
//

#import "DraggedTableViewCell.h"

@interface DraggedTableViewCell ()

@property (nonatomic, assign) CGFloat viewWidth;
@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, assign) CGFloat gestureInitialLocationX;

@property (nonatomic, assign) CGRect mainCellContentFinalPosition;
@property (nonatomic, strong) NSMutableArray *arrPopOutViewFinalPosition;

@property (nonatomic, strong) UIView *viewMainCellContent;
@property (nonatomic, strong) NSMutableArray *arrPopOutButtons;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, assign) CGFloat panGestureVelocity;

@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, assign) BOOL isPoppingOut;

@end

@implementation DraggedTableViewCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier forTableView:(UITableView *)tableView withDeviceViewWidth:(CGFloat)width andCellHeight:(CGFloat)height
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.viewWidth = width;
        self.viewHeight = height;
        
        self.tableView = tableView;
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(handlePanGesture:)];
        self.panGestureRecognizer.delegate = self;
        [self.contentView addGestureRecognizer:self.panGestureRecognizer];
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(handleTapGesture:)];
        self.tapGestureRecognizer.delegate = self;
        [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
        
        self.arrPopOutButtons = [[NSMutableArray alloc] init];
        self.arrPopOutViewFinalPosition = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)addSubviewAsContent:(UIView *)subview
{
    self.viewWidth = subview.frame.size.width;
    self.viewHeight = subview.frame.size.height;
    
    self.mainCellContentFinalPosition = CGRectMake(0, 0, self.viewWidth, subview.frame.size.height);
    self.viewMainCellContent = subview;
    [self.viewMainCellContent setFrame:self.mainCellContentFinalPosition];
    
    self.isLocked = NO;
    self.isPoppingOut = NO;
    
    self.coverView = [[UIView alloc] initWithFrame:self.mainCellContentFinalPosition];
    self.coverView.userInteractionEnabled = NO;
    [self.contentView addSubview:self.coverView];
    [self.contentView addSubview:self.viewMainCellContent];
    
    return YES;
}

- (BOOL)addSubviewAsPopOutButton:(UIView *)subview
{
    [self.arrPopOutButtons addObject:subview];
    [self.arrPopOutViewFinalPosition addObject:[NSValue valueWithCGRect:subview.frame]];
    
    [self.contentView addSubview:subview];
    
    return YES;
}

- (void)removeAllSubviewsFromContentView
{
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.arrPopOutButtons removeAllObjects];
    [self.arrPopOutViewFinalPosition removeAllObjects];
}

#pragma mark - handle tap gesture
- (void)handleTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (self.isLocked) {
        [self dissmissPoppingViews:tapGestureRecognizer];
    } else {
        if (!self.isPoppingOut) {
            ;
        } else {
            [self respondsToTapGesture:tapGestureRecognizer];
        }
    }
}

- (void)respondsToTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CGFloat tapGestureOriginX = [tapGestureRecognizer locationInView:self].x;
    CGFloat offset = self.viewWidth - [self popOutButtonsWidth];
    if (tapGestureOriginX < offset) {
        [self dissmissPoppingViews:tapGestureRecognizer];
    } else {
        NSInteger index = [self tappedOnButton:tapGestureOriginX];
        [self passIndexToTableView:index];
    }
}

- (NSInteger)tappedOnButton:(CGFloat)tappedPointX
{
    NSInteger index = -1;
    for (NSInteger indexPath = [self.arrPopOutViewFinalPosition count] - 1; indexPath >= 0; indexPath--) {
        CGFloat originXAtIndexPath = [[self.arrPopOutViewFinalPosition objectAtIndex:indexPath] CGRectValue].origin.x;
        if (tappedPointX > originXAtIndexPath) {
            return indexPath;
        }
    }
    return index;
}

- (void)passIndexToTableView:(NSInteger)index
{
    if (index >= 0) {
        if ([self.delegate respondsToSelector:@selector(tapGestureTriggeredOnIndex:inCell:)]) {
            [self.delegate tapGestureTriggeredOnIndex:index inCell:self];
        }
    }
}

#pragma mark - handle pan gesture
- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (self.tableView.isDragging) {
        [self dissmissPoppingViews:panGestureRecognizer];
    } else if (!self.tableView.isDecelerating) {
        if (!self.isLocked) {
            [self respondsToPanGesture:panGestureRecognizer];
        } else {
            [self dissmissPoppingViews:panGestureRecognizer];
        }
    }
}

- (void)respondsToPanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    [panGestureRecognizer setTranslation:CGPointZero
                                  inView:panGestureRecognizer.view];
    
    CGFloat originLocationX = [panGestureRecognizer locationInView:self].x;
    CGPoint vel = [panGestureRecognizer velocityInView:panGestureRecognizer.view];
    
    CGPoint gestureVelocity = [panGestureRecognizer velocityInView:self];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        [self setGestureInitialLocation:originLocationX];
    }
    if (panGestureRecognizer.state != UIGestureRecognizerStateEnded)
    {
        self.panGestureVelocity = gestureVelocity.x;
        [self setTableViewScrollEnable:NO];
        
        if (vel.x < 0)
        {
            [self animationWhilepanGestureMoveInPosition:originLocationX];
        } else if (vel.x > 0) {
            [self animationWhilepanGestureMoveInPosition:originLocationX];
        }
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.isPoppingOut) {
            if (self.panGestureVelocity > 5 || self.viewMainCellContent.frame.origin.x > -self.viewWidth*0.2) {
                [self resetViews];
            } else {
                [self adjustCellViewToTheFitPositionWhileSwipingToLeft];
            }
        } else {
            if (self.panGestureVelocity < -5 || self.viewMainCellContent.frame.origin.x < -self.viewWidth*0.8) {
                [self adjustCellViewToTheFitPositionWhileSwipingToLeft];
            } else {
                [self resetViews];
            }
        }
        [self setTableViewScrollEnable:YES];
        
    }
}

#pragma mark - animation for views
- (void)animationWhilepanGestureMoveInPosition:(CGFloat)locationX
{
    CGRect newFrameForCellView = self.mainCellContentFinalPosition;
    newFrameForCellView.origin.x = newFrameForCellView.origin.x - self.gestureInitialLocationX + locationX;
    if (newFrameForCellView.origin.x + [self popOutButtonsWidth] + 15 <= 0) {
        newFrameForCellView.origin.x = - [self popOutButtonsWidth] - 15;
    }
    
    NSInteger arrPopOutButtonNumber = [self.arrPopOutViewFinalPosition count];
    NSMutableArray *newFrameForPopOutButtons = [[NSMutableArray alloc] init];
    for (NSInteger indexPath = 0; indexPath < arrPopOutButtonNumber; indexPath++) {
        CGRect newFrame = [[self.arrPopOutViewFinalPosition objectAtIndex:indexPath] CGRectValue];
        newFrame.origin.x = newFrame.origin.x - (self.gestureInitialLocationX - locationX)*[self popOutButtonWidthFromIndexPath:indexPath]/[self popOutButtonsWidth];
        if (newFrame.origin.x + [self popOutButtonWidthFromIndexPath:indexPath] <= self.viewWidth) {
            newFrame.origin.x = self.viewWidth - [self popOutButtonWidthFromIndexPath:indexPath];
        }
        [newFrameForPopOutButtons addObject:[NSValue valueWithCGRect:newFrame]];
    }
    
    [UIView animateWithDuration:0
                     animations:^{
                         self.viewMainCellContent.frame = newFrameForCellView;
                         
                         for (NSInteger indexPath = 0; indexPath < arrPopOutButtonNumber; indexPath++) {
                             UIView *view = [self.arrPopOutButtons objectAtIndex:indexPath];
                             view.frame = [[newFrameForPopOutButtons objectAtIndex:indexPath] CGRectValue];
                         }
                     }
                     completion:^(BOOL finished){}];
}

#pragma mark - set Gesture's initial Location
- (void)setGestureInitialLocation:(CGFloat)gestureInitialLocationX
{
    self.gestureInitialLocationX = gestureInitialLocationX;
}

- (void)adjustCellViewToTheFitPositionWhileSwipingToLeft
{
    CGRect newFrameForMainCell = self.viewMainCellContent.frame;
    
    CGFloat duration = [self animationsDurationWithDisplacement:[self popOutButtonsWidth]+self.viewMainCellContent.frame.origin.x
                                                       andSpeed:self.panGestureVelocity];
    
    NSInteger arrPopOutButtonNumber = [self.arrPopOutViewFinalPosition count];
    for (NSInteger indexPath = 0; indexPath < arrPopOutButtonNumber; indexPath++) {
        CGRect newFrame = [[self.arrPopOutViewFinalPosition objectAtIndex:indexPath] CGRectValue];
        newFrame.origin.x = self.viewWidth - [self popOutButtonWidthFromIndexPath:indexPath];
        
        [self.arrPopOutViewFinalPosition replaceObjectAtIndex:indexPath withObject:[NSValue valueWithCGRect:newFrame]];
    }
    
    if (self.viewMainCellContent.frame.origin.x + [self popOutButtonsWidth] != 0) {
        newFrameForMainCell.origin.x = - [self popOutButtonsWidth];
    }
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionTransitionCurlDown
                     animations:^{
                         self.viewMainCellContent.frame = newFrameForMainCell;
                         for (NSInteger indexPath = 0; indexPath < arrPopOutButtonNumber; indexPath++) {
                             UIView *view = [self.arrPopOutButtons objectAtIndex:indexPath];
                             view.frame = [[self.arrPopOutViewFinalPosition objectAtIndex:indexPath] CGRectValue];
                         }
                     }
                     completion:^(BOOL finished){
                         self.isPoppingOut = YES;
                         [self lockAllCellsBesides:self];
                     }];
    self.mainCellContentFinalPosition = newFrameForMainCell;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)resetViews
{
    CGRect resetFrameForCellView = CGRectMake(0, 0, self.viewWidth, self.mainCellContentFinalPosition.size.height);
    
    CGFloat duration = [self animationsDurationWithDisplacement:self.mainCellContentFinalPosition.origin.x
                                                       andSpeed:self.panGestureVelocity];
    
    self.mainCellContentFinalPosition = resetFrameForCellView;
    NSInteger arrPopOutButtonNumber = [self.arrPopOutViewFinalPosition count];
    for (NSInteger indexPath = 0; indexPath < arrPopOutButtonNumber; indexPath++) {
        CGRect newFrame = [[self.arrPopOutViewFinalPosition objectAtIndex:indexPath] CGRectValue];
        newFrame.origin.x = self.viewWidth;
        
        [self.arrPopOutViewFinalPosition replaceObjectAtIndex:indexPath
                                                   withObject:[NSValue valueWithCGRect:newFrame]];
    }
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.viewMainCellContent.frame = resetFrameForCellView;
                         for (NSInteger indexPath = 0; indexPath < arrPopOutButtonNumber; indexPath++) {
                             UIView *view = [self.arrPopOutButtons objectAtIndex:indexPath];
                             view.frame = [[self.arrPopOutViewFinalPosition objectAtIndex:indexPath] CGRectValue];
                         }
                     }
                     completion:^(BOOL finished){
                         self.isPoppingOut = NO;
                     }];
    
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
}

- (void)gestureDidEnd
{
    [self unlockAllCells];
}

- (void)dissmissPoppingViews:(UIGestureRecognizer *)gestureRecognizer
{
    [self dismissAllPoppingoutViews];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self performSelector:@selector(gestureDidEnd) withObject:nil afterDelay:0.2];
    }
}

- (void)disablePanGesture
{
    self.panGestureRecognizer.enabled = NO;
}

- (void)enablePanGesture
{
    self.panGestureRecognizer.enabled = YES;
}

- (void)lockCellView
{
    self.isLocked = YES;
}

- (void)unlockCellView
{
    self.isLocked = NO;
}

- (BOOL)ifHadLocked
{
    return self.isLocked;
}

//calc max offset
- (CGFloat)popOutButtonsWidth
{
    CGFloat popOutButtonsWidth = 0;
    for (NSInteger indexPath = 0; indexPath < [self.arrPopOutButtons count]; indexPath++) {
        UIView *tmp = [self.arrPopOutButtons objectAtIndex:indexPath];
        popOutButtonsWidth += tmp.frame.size.width;
    }
    return popOutButtonsWidth;
}

//calc offset form indexPath
- (CGFloat)popOutButtonWidthFromIndexPath:(NSInteger)index
{
    CGFloat popOutButtonsWidth = 0;
    for (NSInteger indexPath = index; indexPath < [self.arrPopOutButtons count]; indexPath++) {
        UIView *tmp = [self.arrPopOutButtons objectAtIndex:indexPath];
        popOutButtonsWidth += tmp.frame.size.width;
    }
    return popOutButtonsWidth;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    if (gestureRecognizer == self.panGestureRecognizer) {
//        CGPoint translation = [self.panGestureRecognizer translationInView:self];
//        if (fabs(translation.y) > fabs(translation.x)) {
//            if (self.tableView.isDragging) {
////                [self scrollViewBeginDragging];
//            }
//        }
//    }
//    return YES;
//}

- (CGFloat)animationsDurationWithDisplacement:(CGFloat)displacement andSpeed:(CGFloat)speed
{
    CGFloat duration = fabs(displacement)/fabs(speed);
    if (duration >= 0.25) {
        duration = 0.25;
    }
    if (duration <= 0.1) {
        duration = 0.1;
    }
    return duration;
}

#pragma mark - tableViewCell Delegate
- (void)lockAllCellsBesides:(DraggedTableViewCell *)cell
{
    NSArray *visibleTableViewCell = [self.tableView visibleCells];
    for (NSInteger index = 0; index < [visibleTableViewCell count]; index++) {
        if ([visibleTableViewCell objectAtIndex:index] != cell) {
            [[visibleTableViewCell objectAtIndex:index] lockCellView];
        }
    }
}

- (void)unlockAllCells
{
    NSArray *visibleTableViewCell = [self.tableView visibleCells];
    for (NSInteger index = 0; index < [visibleTableViewCell count]; index++) {
        [[visibleTableViewCell objectAtIndex:index] unlockCellView];
    }
}

- (void)dismissAllPoppingoutViews
{
    NSArray *visibleTableViewCell = [self.tableView visibleCells];
    for (NSInteger index = 0; index < [visibleTableViewCell count]; index++) {
        if (![[visibleTableViewCell objectAtIndex:index] ifHadLocked]) {
            [[visibleTableViewCell objectAtIndex:index] resetViews];
        }
    }
}

- (void)setTableViewScrollEnable:(BOOL)scrollEnable
{
    self.tableView.scrollEnabled = scrollEnable;
}

////scrollView Delegate
//- (void)scrollViewBeginDragging
//{
//    [self dismissAllPoppingoutViews];
//    NSArray *visibleTableViewCell = [self.tableView visibleCells];
//    for (NSInteger index = 0; index < [visibleTableViewCell count]; index++) {
//        [[visibleTableViewCell objectAtIndex:index] lockCellView];
//    }
//}

@end
