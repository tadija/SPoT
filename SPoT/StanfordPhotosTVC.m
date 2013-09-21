//
//  StanfordPhotosTVC.m
//  SPoT
//
//  Created by Marko Tadić on 21.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "StanfordPhotosTVC.h"

@interface StanfordPhotosTVC ()

@end

@implementation StanfordPhotosTVC

#define RECENT_KEY @"Recent_photos"
#define RECENTS_LIMIT 10
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the photo
    NSDictionary *photo = self.photos[indexPath.row];
    // get the photos saved to recent
    NSMutableArray *photos = [[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:RECENT_KEY];
    if (!photos) photos = [NSMutableArray array];
    if (![photos containsObject:photo]) [photos insertObject:photo atIndex:0];
    if ([photos count] > RECENTS_LIMIT) [photos removeLastObject];
    // set recent photos
    [[NSUserDefaults standardUserDefaults] setObject:photos forKey:RECENT_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end