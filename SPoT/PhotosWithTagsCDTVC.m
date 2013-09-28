//
//  PhotosWithTagsCDTVC.m
//  SPoT
//
//  Created by Marko Tadić on 28.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "PhotosWithTagsCDTVC.h"
#import "Photo.h"
#import "FlickrFetcher.h"

@implementation PhotosWithTagsCDTVC

- (void)setTag:(Tag *)tag
{
    _tag = tag;
    self.title = [tag.name capitalizedString];
    [self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
    if (self.tag.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"tags contains %@", self.tag];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.tag.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    photo.lastViewedDate = [NSDate date];
}

@end
