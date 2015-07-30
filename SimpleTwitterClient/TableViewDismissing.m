//
//  TableViewDismissing.m
//  SimpleTwitterClient
//
//  Created by Vova Musiienko on 30.07.15.
//  Copyright (c) 2015 muhaos.com. All rights reserved.
//

#import "TableViewDismissing.h"

@implementation TableViewDismissing


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if ([self.dismissingDelegate respondsToSelector:@selector(tableViewTapped)]) {
        [self.dismissingDelegate tableViewTapped];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
