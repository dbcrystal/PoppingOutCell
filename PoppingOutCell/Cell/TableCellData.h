//
//  TableCellData.h
//  test_for_request
//
//  Created by LAN on 1/16/15.
//  Copyright (c) 2015 LAN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableCellData : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, assign) NSInteger cellType;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;

- (TableCellData *)initWithRequestName:(NSString *)name andType:(NSInteger)cellType;
- (TableCellData *)initWithRequestSender:(NSString *)name withGroupName:(NSString *)groupName;

@end
