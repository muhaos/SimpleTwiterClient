//
//  Utils.m
//  SimpleTwitterClient
//
//  Created by Vova Musiienko on 30.07.15.
//  Copyright (c) 2015 muhaos.com. All rights reserved.
//

#import "Utils.h"
#import "MBProgressHUD.h"


@implementation Utils

+ (void) showHUDWithText:(NSString*)text inView:(UIView*)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO; // allow user to iterate with background view
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    [hud hide:YES afterDelay:3.0f];
}



@end
