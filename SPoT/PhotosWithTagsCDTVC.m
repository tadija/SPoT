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
#import "SharedDocumentHandler.h"
#import "Tag+Create.h"

@interface PhotosWithTagsCDTVC() <UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSPredicate *searchPredicate;
@end

@implementation PhotosWithTagsCDTVC

- (void)setTag:(Tag *)tag
{
    _tag = tag;
    self.title = [tag.name capitalizedString];
    [self refreshFetchedResultsController];
}

- (void)viewDidLoad
{
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.searchBar.delegate = self;
    // hide the search bar by default
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)refreshFetchedResultsController
{
    if (self.tag.managedObjectContext) {
        // change sections for "All" tag
        NSString *sortDescriptorKey = @"title";
        NSString *sectionNameKey = @"firstLetter";
        if ([self.tag.name isEqualToString:[Tag allTag]]) {
            sortDescriptorKey = @"firstTag";
            sectionNameKey = @"firstTag";
        }
        // get all photos with self.tag
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sortDescriptorKey ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"tags CONTAINS %@", self.tag];
        if (self.searchPredicate) {
            request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[request.predicate, self.searchPredicate]];
        }
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.tag.managedObjectContext sectionNameKeyPath:sectionNameKey cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark UITableView

// update photo.lastViewDate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    photo.lastViewedDate = [NSDate date];
}

// enable deleting of photos
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // delete tag if it only has this photo and delete all tags from photo
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        for (Tag *tag in photo.tags) {
            if ([tag.photos count] == 1) [self.tag.managedObjectContext deleteObject:tag];
        }
        photo.tags = nil;
        [[SharedDocumentHandler sharedInstance] saveDocument];
    }
}

// hide section index titles when searching
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([self.searchBar isFirstResponder]) {
        return nil;
    } else {
        return [self.fetchedResultsController sectionIndexTitles];
    }
}

#pragma mark UISearchBar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length]) {
        self.searchPredicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", searchText];
    } else {
        self.searchPredicate = nil;
    }
    [self refreshFetchedResultsController];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

@end
