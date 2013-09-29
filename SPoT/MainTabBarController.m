//
//  MainTabBarController.m
//  SPoT
//
//  Created by Marko Tadić on 29.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "MainTabBarController.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface MainTabBarController () <UISplitViewControllerDelegate>
@end

@implementation MainTabBarController

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

#pragma mark UISplitViewController delegate methods

// hide master view controller in portrait orientation
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation) ? YES : NO;
}

// add popover bar button item when hiding master
- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Photos";
    [[self splitViewDetailWithBarButtonItem] setSplitViewBarButtonItem:barButtonItem];
    self.masterPopover = pc;
}

// remove popover bar button item when showing master
- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{    
    [[self splitViewDetailWithBarButtonItem] setSplitViewBarButtonItem:nil];
    self.masterPopover = nil;
}

#pragma mark SplitViewBarButtonItemPresenter

- (id <SplitViewBarButtonItemPresenter>)splitViewDetailWithBarButtonItem
{
    // return detail view controller which conforms to protocol of SplitViewBarButtonItemPresenter
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

@end
