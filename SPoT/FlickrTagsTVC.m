//
//  FlickrTagsTVC.m
//  SPoT
//
//  Created by Marko Tadić on 19.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "FlickrTagsTVC.h"
#import "FlickrFetcher.h"

@interface FlickrTagsTVC ()
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSDictionary *tagsWithPhotos;
@end

@implementation FlickrTagsTVC

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self createTagsWithPhotos];
    [self.tableView reloadData];
}

- (void)createTagsWithPhotos
{
    NSMutableDictionary *tagsWithPhotos = [NSMutableDictionary dictionary];
    for (NSDictionary *photo in self.photos) {
        for (NSString *tag in [[photo[FLICKR_TAGS] description] componentsSeparatedByString:@" "]) {
            if (![@[@"cs193pspot", @"portrait", @"landscape"] containsObject:tag]) {
                NSMutableArray *photosWithTag = tagsWithPhotos[tag];
                if (!photosWithTag) {
                    photosWithTag = [NSMutableArray array];
                    tagsWithPhotos[tag] = photosWithTag;
                }
                [photosWithTag addObject:photo];
            }
        }
    }
    self.tagsWithPhotos = tagsWithPhotos;
    self.tags = [[tagsWithPhotos allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show photos with tag"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setPhotos:)]) {
                    NSString *tag = self.tags[indexPath.row];
                    NSArray *photos = [self.tagsWithPhotos[tag] sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:FLICKR_PHOTO_TITLE ascending:YES]]];
                    [segue.destinationViewController performSelector:@selector(setPhotos:) withObject:photos];
                    [segue.destinationViewController setTitle:[tag capitalizedString]];
                }
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tag Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *tag = self.tags[indexPath.row];
    int photoCount = [self.tagsWithPhotos[tag] count];
    cell.textLabel.text = [tag capitalizedString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photo%@", photoCount, photoCount > 1 ? @"s" : @""];
    
    return cell;
}

@end
