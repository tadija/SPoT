//
//  RecentPhotosTVC.m
//  SPoT
//
//  Created by Marko Tadić on 21.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "RecentPhotosTVC.h"

@interface RecentPhotosTVC ()

@end

@implementation RecentPhotosTVC

#define RECENT_KEY @"Recent_photos"
- (void)viewWillAppear:(BOOL)animated
{
    self.photos = [[NSUserDefaults standardUserDefaults] arrayForKey:RECENT_KEY];
}

- (IBAction)clearRecents:(UIBarButtonItem *)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:RECENT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.photos = nil;
}

@end
