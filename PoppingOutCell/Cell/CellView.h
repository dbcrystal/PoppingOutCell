//
//  TableCellView.h
//  test_for_request
//
//  Created by LAN on 1/16/15.
//  Copyright (c) 2015 LAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableCellData.h"

@interface CellView : UIView <UIGestureRecognizerDelegate>

- (id)initWithFrame:(CGRect)frame andCellData:(TableCellData *)cellData;

@end
