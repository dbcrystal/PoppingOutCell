//
//  TableCellData.m
//  test_for_request
//
//  Created by LAN on 1/16/15.
//  Copyright (c) 2015 LAN. All rights reserved.
//

#import "TableCellData.h"

@interface TableCellData ()

@end

@implementation TableCellData

- (TableCellData *)initWithRequestName:(NSString *)name andType:(NSInteger)cellType
{
//    self.name = name;
//    self.groupName = @"";
//    self.cellType = cellType;
//    
//    if (cellType == typedFriendRequest) {
//        self.title = name;
//        self.subtitle = [NSString stringWithFormat:@"请求添加你为好友"];
//    } else if (cellType == typedGroupRequest) {
//        self.title = [NSString stringWithFormat:@"%@邀请", name];
//        self.subtitle = [NSString stringWithFormat:@"加入群"];
//    } else if (cellType == typedMyRequest) {
//        self.title = [NSString stringWithFormat:@"添加%@为好友", name];
//        self.subtitle = [NSString stringWithFormat:@"请求等待中"];
//    }
    
    return self;
}

- (TableCellData *)initWithRequestSender:(NSString *)name withGroupName:(NSString *)groupName
{
//    self.name = name;
//    self.groupName = groupName;
//    self.cellType = typedGroupRequest;
//    
//    self.title = [NSString stringWithFormat:@"%@邀请", name];
//    self.subtitle = [NSString stringWithFormat:@"加入%@群", groupName];
    
    return self;
}

@end
