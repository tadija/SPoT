//
//  PhotosCDTVC.m
//  SPoT
//
//  Created by Marko Tadić on 28.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "PhotosCDTVC.h"
#import "Photo.h"
#import "UIApplication+NetworkActivity.h"
#import "FlickrFetcher.h"
#import "SplitViewBarButtonItemPresenter.h"
#import "SharedDocumentHandler.h"

@interface PhotosCDTVC() <UISplitViewControllerDelegate>
@end

@implementation PhotosCDTVC

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo"];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    
    UIImage *thumbnailImage = nil;
    // if thumbnail is not cached in CoreData get it from Flickr
    if (!photo.thumbnail) {
        dispatch_queue_t thumbnailFetch = dispatch_queue_create("Get thumbnail image", NULL);
        dispatch_async(thumbnailFetch, ^{
            [[UIApplication sharedApplication] showNetworkActivityIndicator];
            NSData *thumbnailData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]];
            [[UIApplication sharedApplication] hideNetworkActivityIndicator];
            dispatch_async(dispatch_get_main_queue(), ^{
                photo.thumbnail = thumbnailData;
                [[SharedDocumentHandler sharedInstance] saveDocument];
            });
        });
    } else { // else get it from CoreData
        thumbnailImage = [UIImage imageWithData:photo.thumbnail];
    }
    cell.imageView.image = thumbnailImage;
    
    return cell;
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"setImageURL:"]) {
            Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
            NSURL *photoURL = [NSURL URLWithString:photo.imageURL];
            if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:photoURL];
                [segue.destinationViewController setTitle:photo.title];
                [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
            }
        }
    }
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

- (void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController
{
    UIBarButtonItem *splitViewBarButtonItem = [[self splitViewDetailWithBarButtonItem] splitViewBarButtonItem];
    [[self splitViewDetailWithBarButtonItem] setSplitViewBarButtonItem:nil];
    if (splitViewBarButtonItem) [destinationViewController setSplitViewBarButtonItem:splitViewBarButtonItem];
}

@end
