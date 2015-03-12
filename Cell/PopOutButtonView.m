//
//  popOutButtonView.m
//  test_for_request
//
//  Created by LAN on 1/20/15.
//  Copyright (c) 2015 LAN. All rights reserved.
//

#import "PopOutButtonView.h"

@implementation PopOutButtonView

- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title andBackgroundColor:(UIColor *)backgroundColor
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:backgroundColor];
    }
    return self;
}

@end
