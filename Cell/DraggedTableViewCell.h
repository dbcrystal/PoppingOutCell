//
//  TableViewCell.h
//  test_for_request
//
//  Created by LAN on 1/16/15.
//  Copyright (c) 2015 LAN. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DraggedTableViewCell;

@protocol TableViewCellDelegate <NSObject>

@required

@optional
//Will be triggered when tap gesture occured on popping out buttons, this method will show you triggered cell(id) and button's index.
- (void)tapGestureTriggeredOnIndex:(NSInteger)index inCell:(DraggedTableViewCell *)draggedTableViewCell;

@end

@interface DraggedTableViewCell : UITableViewCell <UIGestureRecognizerDelegate>

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier forTableView:(UITableView *)tableView withDeviceViewWidth:(CGFloat)width andCellHeight:(CGFloat)height;

//add main cell view. This view will show to users first.
//Subview's frame would like to be (0, 0, /*Your screen or tableView width*/, cell Height)
- (BOOL)addSubviewAsContent:(UIView *)subview;

//add buttons which will pop out from right of the screen
//buttons will be displayed from left to right, depending on the order you add the subviews to cell
//Subview's frame would like to be (/*Your screen or tableView width*/, 0, /*Your subview's width*/, /*Your subview's height*/)
- (BOOL)addSubviewAsPopOutButton:(UIView *)subview;


- (void)resetViews;
- (void)clickWithIndex:(NSInteger)index;//点击按钮
- (void)cellSeleted;//点击cell

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) id<TableViewCellDelegate> delegate;

@end
