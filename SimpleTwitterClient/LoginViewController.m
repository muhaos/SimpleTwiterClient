//
//  LoginViewController.m
//  SimpleTwitterClient
//
//  Created by Vova Musiienko on 29.07.15.
//  Copyright (c) 2015 muhaos.com. All rights reserved.
//

#import "LoginViewController.h"
#import <TwitterKit/TwitterKit.h>
#import "Utils.h"
#import "AppDelegate.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak LoginViewController* weakSelf = self;
    
    TWTRLogInButton* logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession* session, NSError* error) {
        if (session) {
            [weakSelf proceedToMainView];
        } else {
            [Utils showHUDWithText:[NSString stringWithFormat:@"Oops: %@", [error localizedDescription]] inView:weakSelf.view.window];
        }
    }];
    
    logInButton.center = self.view.center;
    [self.view addSubview:logInButton];
}


- (void) proceedToMainView
{
    [((AppDelegate*)[UIApplication sharedApplication].delegate) showRootVC];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
