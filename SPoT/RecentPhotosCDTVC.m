//
//  RecentPhotosCDTVC.m
//  SPoT
//
//  Created by Marko Tadić on 28.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "RecentPhotosCDTVC.h"
#import "SharedDocumentHandler.h"
#import "Photo.h"

@interface RecentPhotosCDTVC()
@property (nonatomic, retain) NSManagedObjectContext *context;
@end

@implementation RecentPhotosCDTVC

- (NSManagedObjectContext *)context
{
    if (!_context) _context = [SharedDocumentHandler sharedInstance].document.managedObjectContext;
    return _context;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupFetchedResultsController];
}

#define MAX_RECENT_COUNT 10
- (void)setupFetchedResultsController
{
    if (self.context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastViewedDate" ascending:NO selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"lastViewedDate != nil AND tags.@count > 0"];
        request.fetchLimit = MAX_RECENT_COUNT;
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (IBAction)clearRecents:(UIBarButtonItem *)sender
{
    if (self.context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        NSError *error = nil;
        NSArray *matches = [self.context executeFetchRequest:request error:&error];
        // remove lastViewedDate from all photos
        if (!error) {
            for (Photo *photo in matches) {
                photo.lastViewedDate = nil;
            }
            // force save the document
            [[SharedDocumentHandler sharedInstance] saveDocument];
        }
    }
}

@end
