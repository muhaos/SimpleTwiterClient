//
//  AppDelegate.h
//  SimpleTwitterClient
//
//  Created by Vova Musiienko on 29.07.15.
//  Copyright (c) 2015 muhaos.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (NSURL *)applicationDocumentsDirectory;
- (void) showLoginVC;
- (void) showRootVC;

@end

