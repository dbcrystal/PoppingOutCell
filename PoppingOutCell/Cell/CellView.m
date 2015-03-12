
//
//  TableCellView.m
//  test_for_request
//
//  Created by LAN on 1/16/15.
//  Copyright (c) 2015 LAN. All rights reserved.
//

#import "CellView.h"

@interface CellView ()

@property (nonatomic, strong) TableCellData *cellData;

@end

@implementation CellView

- (id)initWithFrame:(CGRect)frame andCellData:(TableCellData *)cellData
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.cellData = cellData;
        
        [self drawCellView];
    }
    return self;
}

- (void)drawCellView
{
    UIView *tmp = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-20, 0, 20, tableViewCellHeight)];
    [tmp setBackgroundColor:[UIColor blueColor]];
    [self addSubview:tmp];    
}

@end
