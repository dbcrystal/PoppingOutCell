//
//  ViewController.m
//  test_for_request
//
//  Created by LAN on 1/14/15.
//  Copyright (c) 2015 LAN. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel *lblFriendsRequest;
@property (nonatomic, strong) UILabel *lblGroupsRequest;
@property (nonatomic, strong) UILabel *lblMyRequest;

@property (nonatomic, strong) UIView *viewUnderline;

@property (nonatomic, strong) UITableView *tableViewRequestList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    const NSInteger viewWidth = self.view.frame.size.width;
    const NSInteger viewHeight = self.view.frame.size.height;
    
    //init with tagBar
    UIView *viewTagBar = [[UIView alloc] initWithFrame:CGRectMake(0, navBarHeight, viewWidth, tagBarHeight)];
    [viewTagBar setBackgroundColor:[UIColor colorWithRed:238.0/250.0
                                                   green:238.0/250.0
                                                    blue:238.0/250.0
                                                   alpha:1.0]];
    CALayer *tagBarBorder = [CALayer layer];
    [tagBarBorder setFrame:CGRectMake(0.0f, tagBarHeight - 1.0f, viewWidth, 1.0f)];
    [tagBarBorder setBackgroundColor:[UIColor colorWithRed:220.0/255.0
                                                     green:220.0/255.0
                                                      blue:220.0/255.0
                                                     alpha:1.0].CGColor];
    
    [viewTagBar.layer addSublayer:tagBarBorder];
    
    
    NSInteger unitLength = viewWidth / 16;
    
    //init with tag One
    self.lblFriendsRequest = [[UILabel alloc] initWithFrame:CGRectMake(unitLength, 10, unitLength * 4, 20)];
    self.lblFriendsRequest.text = @"Request";
    self.lblFriendsRequest.textAlignment = NSTextAlignmentCenter;
    [self.lblFriendsRequest setTextColor:[UIColor redColor]];
    self.lblFriendsRequest.userInteractionEnabled = YES;
    UITapGestureRecognizer *gestureFriendsRequest = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(clickedFriendsRequestLable:)];
    [self.lblFriendsRequest addGestureRecognizer:gestureFriendsRequest];
    [viewTagBar addSubview:self.lblFriendsRequest];
    
    //init with tag Two
    self.lblGroupsRequest = [[UILabel alloc] initWithFrame:CGRectMake(unitLength * 6, 10, unitLength * 4, 20)];
    self.lblGroupsRequest.text = @"Request";
    self.lblGroupsRequest.textAlignment = NSTextAlignmentCenter;
    [self.lblGroupsRequest setTextColor:[self tagsDefaultColor]];
    self.lblGroupsRequest.userInteractionEnabled = YES;
    UITapGestureRecognizer *gestureGroupsRequest = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(clickedGroupsRequestLable:)];
    [self.lblGroupsRequest addGestureRecognizer:gestureGroupsRequest];
    [viewTagBar addSubview:self.lblGroupsRequest];
    
    //init with tag Three
    self.lblMyRequest = [[UILabel alloc] initWithFrame:CGRectMake(unitLength * 11, 10, unitLength * 4, 20)];
    self.lblMyRequest.text = @"Request";
    self.lblMyRequest.textAlignment = NSTextAlignmentCenter;
    [self.lblMyRequest setTextColor:[self tagsDefaultColor]];
    self.lblMyRequest.userInteractionEnabled = YES;
    UITapGestureRecognizer *gestureMyRequest = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(clickMyRequestLable:)];
    [self.lblMyRequest addGestureRecognizer:gestureMyRequest];
    [viewTagBar addSubview:self.lblMyRequest];
    
    //init with tagBarUnderline
    self.viewUnderline = [[UIView alloc] initWithFrame:CGRectMake(unitLength, tagBarHeight - 3, unitLength * 4, 3)];
    [self.viewUnderline setBackgroundColor:[UIColor redColor]];
    [viewTagBar addSubview:self.viewUnderline];
    
    [self.view addSubview:viewTagBar];
    
    //init with tableView
    self.tableViewRequestList = [[UITableView alloc] initWithFrame:
                                 CGRectMake(0, navBarHeight + tagBarHeight, viewWidth, viewHeight - navBarHeight - tagBarHeight - tabBarHeight)];
    self.tableViewRequestList.delegate = self;
    self.tableViewRequestList.dataSource = self;
    //    self.tableViewRequestList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableViewRequestList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor *)tagsDefaultColor
{
    return [UIColor colorWithRed:100.0/250.0
                           green:100.0/250.0
                            blue:100.0/250.0
                           alpha:1.0];
}

- (NSInteger)unitLength
{
    NSInteger viewWidth = self.view.frame.size.width;
    return viewWidth / 16;
}

#pragma mark - tags' response
- (void)clickedFriendsRequestLable:(UIButton *)sender
{
    [self animationWhenTapOccuredOnLable:self.lblFriendsRequest];
}

- (void)clickedGroupsRequestLable:(UIButton *)sender
{
    [self animationWhenTapOccuredOnLable:self.lblGroupsRequest];
    [self.tableViewRequestList reloadData];
}

- (void)clickMyRequestLable:(UIButton *)sender
{
    [self animationWhenTapOccuredOnLable:self.lblMyRequest];
}

- (void)animationWhenTapOccuredOnLable:(UILabel *)tappedLable
{
    [self.lblFriendsRequest setTextColor:[self tagsDefaultColor]];
    [self.lblGroupsRequest setTextColor:[self tagsDefaultColor]];
    [self.lblMyRequest setTextColor:[self tagsDefaultColor]];
    
    [tappedLable setTextColor:[UIColor redColor]];
    
    CGRect underlineFrame = self.viewUnderline.frame;
    if (tappedLable == self.lblFriendsRequest) {
        underlineFrame.origin.x = [self unitLength];
        [self moveUnderlineToFrame:underlineFrame];
    }
    
    if (tappedLable == self.lblGroupsRequest) {
        underlineFrame.origin.x = [self unitLength] * 6;
        [self moveUnderlineToFrame:underlineFrame];
    }
    
    if (tappedLable == self.lblMyRequest) {
        underlineFrame.origin.x = [self unitLength] * 11;
        [self moveUnderlineToFrame:underlineFrame];
    }
}

- (void)moveUnderlineToFrame:(CGRect)newFrame
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.viewUnderline.frame = newFrame;
                     }
                     completion:^(BOOL finished){}];
}

#pragma mark - tableView Method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UITableViewCell";
    
    DraggedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[DraggedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:cellIdentifier
                                              forTableView:self.tableViewRequestList
                                       withDeviceViewWidth:self.view.frame.size.width
                                             andCellHeight:tableViewCellHeight];
        
        CellView *viewTableCellView = [[CellView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, tableViewCellHeight)
                                                          andCellData:nil];
        [cell addSubviewAsContent:viewTableCellView];
        
        PopOutButtonView *blockView = [[PopOutButtonView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, 75, tableViewCellHeight)
                                                                     andTitle:nil
                                                           andBackgroundColor:[UIColor colorWithRed:200.0/250.0
                                                                                              green:200.0/250.0
                                                                                               blue:200.0/250.0
                                                                                              alpha:1.0]];
        [cell addSubviewAsPopOutButton:blockView];
        
        PopOutButtonView *rejectView = [[PopOutButtonView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, 90, tableViewCellHeight)
                                                                      andTitle:nil
                                                            andBackgroundColor:[UIColor redColor]];
        [cell addSubviewAsPopOutButton:rejectView];
        
        PopOutButtonView *deleteView = [[PopOutButtonView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, 90, tableViewCellHeight)
                                                                      andTitle:nil
                                                            andBackgroundColor:[UIColor greenColor]];
        [cell addSubviewAsPopOutButton:deleteView];
    }
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableViewCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ;
}

- (void)tapGestureTriggeredOnIndex:(NSInteger)index inCell:(DraggedTableViewCell *)draggedTableViewCell
{
    ;
}

@end
