//
//  TagsCDTVC.m
//  SPoT
//
//  Created by Marko Tadić on 28.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "TagsCDTVC.h"
#import "Tag+Create.h"

@interface TagsCDTVC() <UISearchBarDelegate>
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSPredicate *searchPredicate;
@end

@implementation TagsCDTVC

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self refreshFetchedResultsController];
}

- (void)refreshFetchedResultsController
{
    if (self.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
        NSSortDescriptor *allTagIsFirst = [NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES selector:@selector(compare:)];
        NSSortDescriptor *sortByTagName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        request.sortDescriptors = @[allTagIsFirst, sortByTagName];
        request.predicate = [NSPredicate predicateWithFormat:@"NOT (name IN %@)", [Tag hiddenTags]];
        if (self.searchPredicate) {
            request.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[request.predicate, self.searchPredicate]];
        }
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Tag"];
    
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [tag.name capitalizedString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", [tag.photos count]];
    
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
        if ([segue.identifier isEqualToString:@"setTag:"]) {
            Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setTag:)]) {
                [segue.destinationViewController performSelector:@selector(setTag:) withObject:tag];
            }
        }
    }
}

#pragma mark UISearchBar

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]
                      initWithFrame:self.navigationController.navigationBar.frame];
        self.searchBar.delegate = self;
    }
    return _searchBar;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length]) {
        self.searchPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
    } else {
        self.searchPredicate = nil;
    }
    [self refreshFetchedResultsController];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (IBAction)searchBarButtonPressed:(UIBarButtonItem *)sender
{
    if (self.tableView.tableHeaderView) {
        self.tableView.tableHeaderView = nil;
    } else {
        self.tableView.tableHeaderView = self.searchBar;
        [self.searchBar becomeFirstResponder];
    }
}

@end
