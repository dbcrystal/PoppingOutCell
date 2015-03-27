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
@property (nonatomic, assign) CGFloat panGestureVelocity;

@property (nonatomic, assign) CGRect mainCellContentFinalPosition;

@property (nonatomic, strong) NSMutableArray *arrPopOutViewFinalPosition;
@property (nonatomic, strong) NSMutableArray *arrPopOutButtons;

@property (nonatomic, strong) UIView *viewMainCellContent;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, assign) BOOL isPoppingOut;

@end

@implementation DraggedTableViewCell
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
        
        [self.tapGestureRecognizer requireGestureRecognizerToFail:self.panGestureRecognizer];
        
        self.arrPopOutButtons = [[NSMutableArray alloc] init];
        self.arrPopOutViewFinalPosition = [[NSMutableArray alloc] init];
        
        //“手势被取消”的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelGestureRecognizer) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//手势被取消时，恢复原位，打开tap手势
- (void)cancelGestureRecognizer
{
    self.tapGestureRecognizer.enabled = YES;
    
    CGRect resetFrameForCellView = CGRectMake(0, 0, self.viewWidth, self.mainCellContentFinalPosition.size.height);
    
    self.mainCellContentFinalPosition = resetFrameForCellView;
    NSInteger arrPopOutButtonNumber = [self.arrPopOutViewFinalPosition count];
    for (NSInteger indexPath = 0; indexPath < arrPopOutButtonNumber; indexPath++) {
        CGRect newFrame = [[self.arrPopOutViewFinalPosition objectAtIndex:indexPath] CGRectValue];
        newFrame.origin.x = self.viewWidth;
        
        [self.arrPopOutViewFinalPosition replaceObjectAtIndex:indexPath
                                                   withObject:[NSValue valueWithCGRect:newFrame]];
    }
    self.viewMainCellContent.frame = resetFrameForCellView;
    for (NSInteger indexPath = 0; indexPath < arrPopOutButtonNumber; indexPath++) {
        UIView *view = [self.arrPopOutButtons objectAtIndex:indexPath];
        view.frame = [[self.arrPopOutViewFinalPosition objectAtIndex:indexPath] CGRectValue];
    }
    
    self.isPoppingOut = NO;
    self.tableView.scrollEnabled = YES;
    [self unlockCellView];
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
        [self dismissAllPoppingoutViews];
    } else {
        if (!self.isPoppingOut) {
            [self cellSeleted];//点击cell
        } else {
            [self respondsToTapGesture:tapGestureRecognizer];
        }
    }
}

- (void)respondsToTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    CGFloat tapGestureOriginX = [tapGestureRecognizer locationInView:self].x;
    CGFloat offset = self.viewWidth - [self getPopOutButtonWidthWithIndex:0];
    if (tapGestureOriginX < offset) {
        [self dismissAllPoppingoutViews];
    } else {
        NSInteger index = [self getButtonIndexWithPositionX:tapGestureOriginX];
        [self touchButtonWithIndex:index];
    }
}

- (NSInteger)getButtonIndexWithPositionX:(CGFloat)tappedPointX
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

- (void)touchButtonWithIndex:(NSInteger)index
{
    if (index >= 0) {
        if ([self.delegate respondsToSelector:@selector(tapGestureTriggeredOnIndex:inCell:)]) {
            [self.delegate tapGestureTriggeredOnIndex:index inCell:self];
        }
        [self clickWithIndex:index];
    }
}

#pragma mark - handle pan gesture
- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    //开始pan手势时，禁用tap手势
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.tapGestureRecognizer.enabled = NO;
    }
    
    //pan手势结束／失败／取消时，恢复tap手势
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.tapGestureRecognizer.enabled = YES;
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateFailed) {
        self.tapGestureRecognizer.enabled = YES;
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        self.tapGestureRecognizer.enabled = YES;
    }
    
    
    if (self.tableView.isDragging ||
        self.tableView.isDecelerating) {
        [self dismissAllPoppingoutViews];
    }
    else
    {
        if (!self.isLocked) {
            [self respondsToPanGesture:panGestureRecognizer];
        } else {
            [self dismissAllPoppingoutViews];
        }
    }
    
}

- (void)respondsToPanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    [panGestureRecognizer setTranslation:CGPointZero
                                  inView:panGestureRecognizer.view];
    
    CGFloat originLocationX = [panGestureRecognizer locationInView:self].x;
    
    
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        self.gestureInitialLocationX = originLocationX;
        return;
    }
    
    
    if (panGestureRecognizer.state != UIGestureRecognizerStateEnded)
    {
        self.panGestureVelocity = [panGestureRecognizer velocityInView:self].x;
        self.tableView.scrollEnabled = NO;
        /*if (vel.x < 0)
         {
         [self animationWhilepanGestureMoveInPosition:originLocationX];
         } else if (vel.x > 0) {
         [self animationWhilepanGestureMoveInPosition:originLocationX];
         }*/
        if (self.panGestureVelocity != 0) {
            [self animationMoveToPosition:originLocationX];
        }
        return;
    }
    
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.isPoppingOut) {
            if (-self.panGestureVelocity / 8 - self.viewMainCellContent.frame.origin.x < [self getPopOutButtonWidthWithIndex:0] / 2){
                // if的说明[self popOutButtonsWidth] - (fabs(self.viewMainCellContent.frame.origin.x) + self.panGestureVelocity / 8) > [self popOutButtonsWidth] / 2
                [self resetViews];
            } else {
                [self showPopOutButton];
            }
        } else {
            if (-self.panGestureVelocity / 8 - self.viewMainCellContent.frame.origin.x > [self getPopOutButtonWidthWithIndex:0] / 2) {
                [self showPopOutButton];
            } else {
                [self resetViews];
            }
        }
        self.tableView.scrollEnabled = YES;
        return;
    }
}

#pragma mark - animation for views
- (void)animationMoveToPosition:(CGFloat)locationX
{

    if (self.gestureInitialLocationX == 0.f) {
        self.gestureInitialLocationX = locationX;
    }
    CGRect newFrameForCellView = self.mainCellContentFinalPosition;
    newFrameForCellView.origin.x = newFrameForCellView.origin.x - self.gestureInitialLocationX + locationX;
    if (newFrameForCellView.origin.x > 15 ) {
        newFrameForCellView.origin.x = 15;//右滑最多到15
    }
    if (newFrameForCellView.origin.x + [self getPopOutButtonWidthWithIndex:0] + 15 <= 0) {
        newFrameForCellView.origin.x = - [self getPopOutButtonWidthWithIndex:0] - 15;
    }
    
    NSInteger arrPopOutButtonNumber = [self.arrPopOutViewFinalPosition count];
    NSMutableArray *newFrameForPopOutButtons = [[NSMutableArray alloc] init];
    for (NSInteger indexPath = 0; indexPath < arrPopOutButtonNumber; indexPath++) {
        CGRect newFrame = [[self.arrPopOutViewFinalPosition objectAtIndex:indexPath] CGRectValue];
        newFrame.origin.x = newFrame.origin.x - (self.gestureInitialLocationX - locationX)*[self getPopOutButtonWidthWithIndex:indexPath]/[self getPopOutButtonWidthWithIndex:0];
        if (newFrame.origin.x + [self getPopOutButtonWidthWithIndex:indexPath] <= self.viewWidth) {
            newFrame.origin.x = self.viewWidth - [self getPopOutButtonWidthWithIndex:indexPath];
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

//viewMainCellContent移动到左边，显示出按钮
- (void)showPopOutButton
{
    CGRect newFrameForMainCell = self.viewMainCellContent.frame;
    
    CGFloat duration = [self getAnimationsDurationWithPositionX:[self getPopOutButtonWidthWithIndex:0]+self.viewMainCellContent.frame.origin.x
                                                       andSpeed:self.panGestureVelocity];
    
    NSInteger arrPopOutButtonNumber = [self.arrPopOutViewFinalPosition count];
    for (NSInteger indexPath = 0; indexPath < arrPopOutButtonNumber; indexPath++) {
        CGRect newFrame = [[self.arrPopOutViewFinalPosition objectAtIndex:indexPath] CGRectValue];
        newFrame.origin.x = self.viewWidth - [self getPopOutButtonWidthWithIndex:indexPath];
        
        [self.arrPopOutViewFinalPosition replaceObjectAtIndex:indexPath withObject:[NSValue valueWithCGRect:newFrame]];
    }
    
    if (self.viewMainCellContent.frame.origin.x + [self getPopOutButtonWidthWithIndex:0] != 0) {
        newFrameForMainCell.origin.x = - [self getPopOutButtonWidthWithIndex:0];
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
}

//viewMainCellContent移动回原始位置,隐藏按钮
- (void)hidePopOutButton
{
    
    CGRect resetFrameForCellView = CGRectMake(0, 0, self.viewWidth, self.mainCellContentFinalPosition.size.height);
    
    CGFloat duration = [self getAnimationsDurationWithPositionX:self.mainCellContentFinalPosition.origin.x
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
}

//index的按钮完全滑出时到最右边的宽度
- (CGFloat)getPopOutButtonWidthWithIndex:(NSInteger)index
{
    CGFloat popOutButtonsWidth = 0;
    for (NSInteger indexPath = index; indexPath < [self.arrPopOutButtons count]; indexPath++) {
        UIView *tmp = [self.arrPopOutButtons objectAtIndex:indexPath];
        popOutButtonsWidth += tmp.frame.size.width;
    }
    return popOutButtonsWidth;
}

//左滑右滑动画的时间限制
- (CGFloat)getAnimationsDurationWithPositionX:(CGFloat)displacement andSpeed:(CGFloat)speed
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

- (void)resetViews
{
    if (self.viewMainCellContent.frame.origin.x != 0) {
        //在滑出的状态动画恢复位置
        [self hidePopOutButton];
    }
    else{
        //非滑出状态不需恢复位置
        self.isPoppingOut = NO;
    }
    self.gestureInitialLocationX = 0.f;//重置手势位置
    [self unlockCellView];
}

- (void)lockCellView
{
    //    NSLog(@"locked %f", self.center.y);
    self.isLocked = YES;
    self.viewMainCellContent.userInteractionEnabled = NO;//滑出后cell上面的按钮不能点击
}

- (void)unlockCellView
{
    //    NSLog(@"unlocked %f", self.center.y);
    self.isLocked = NO;
    self.viewMainCellContent.userInteractionEnabled = YES;
}

- (void)lockAllCellsBesides:(DraggedTableViewCell *)cell
{
    for (DraggedTableViewCell *tempCell in [self.tableView visibleCells]) {
        if (tempCell != cell) {
            [tempCell lockCellView];
        }
    }
}

- (void)dismissAllPoppingoutViews
{
    for (DraggedTableViewCell *tempCell in [self.tableView visibleCells]) {
        [tempCell resetViews];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//子类使用
- (void)clickWithIndex:(NSInteger)index
{
    //点击按钮
}

- (void)cellSeleted
{
    //点击cell
}

#pragma mark - setter/getter
- (void)setGestureInitialLocationX:(CGFloat)gestureInitialLocationX
{
    _gestureInitialLocationX = gestureInitialLocationX;
}

- (void)setIsPoppingOut:(BOOL)isPoppingOut
{
    _isPoppingOut = isPoppingOut;
    if (isPoppingOut) {
        self.viewMainCellContent.userInteractionEnabled = NO;//滑出后cell上面的按钮不能点击
    }
    else{
        self.viewMainCellContent.userInteractionEnabled = YES;
    }
}

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
