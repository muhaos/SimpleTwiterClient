//
//  TableViewDismissing.h
//  SimpleTwitterClient
//
//  Created by Vova Musiienko on 30.07.15.
//  Copyright (c) 2015 muhaos.com. All rights reserved.
//

/*
    Because twiter cells do not allow to just add gesture recognizer into table view for
    handling keyboard dismissing on tap.
 */

#import <UIKit/UIKit.h>

@protocol TableViewDismissingDelegate <NSObject>

- (void) tableViewTapped;

@end



@interface TableViewDismissing : UITableView

@property (nonatomic, weak) id <TableViewDismissingDelegate> dismissingDelegate;


@end
