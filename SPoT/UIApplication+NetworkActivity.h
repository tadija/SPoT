//
//  UIApplication+NetworkActivity.h
//  SPoT
//
//  Created by Marko Tadić on 9/25/13.
//  Copyright (c) 2013 tadija. All rights reserved.
//
//  taken from http://stackoverflow.com/questions/3032192/networkactivityindicatorvisible

#import <UIKit/UIKit.h>

@interface UIApplication (NetworkActivity)
- (void)showNetworkActivityIndicator;
- (void)hideNetworkActivityIndicator;
@end
