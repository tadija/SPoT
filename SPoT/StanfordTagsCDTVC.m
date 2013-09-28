//
//  StanfordTagsCDTVC.m
//  SPoT
//
//  Created by Marko Tadić on 28.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "StanfordTagsCDTVC.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "SharedDocumentHandler.h"
#import "UIApplication+NetworkActivity.h"

@interface StanfordTagsCDTVC()
@property (nonatomic, strong) UIManagedDocument *document;
@end

@implementation StanfordTagsCDTVC

- (UIManagedDocument *)document
{
    if (!_document) _document = [SharedDocumentHandler sharedInstance].document;
    return _document;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext) [self useSharedDocument];
}

- (void)useSharedDocument
{
    // if document does not exist, create it and get its managedObjectContext
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]) {
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = self.document.managedObjectContext;
                [self refresh];
            }
        }];
    // if the document is closed, open it and get its managedObjectContext
    } else if (self.document.documentState == UIDocumentStateClosed) {
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = self.document.managedObjectContext;
            }
        }];
    // otherwise, just get its managedObjectContext
    } else {
        self.managedObjectContext = self.document.managedObjectContext;
    }
}

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Fetch", NULL);
    dispatch_async(fetchQ, ^{
        [[UIApplication sharedApplication] showNetworkActivityIndicator];
        NSArray *photos = [FlickrFetcher stanfordPhotos];
        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
        // put the photos in core data
        [self.managedObjectContext performBlock:^{
            for (NSDictionary *photo in photos) {
                [Photo photoWithFlickrInfo:photo inManagedObjectContext:self.managedObjectContext];
            }
            // force save the document after fetching photos
            [[SharedDocumentHandler sharedInstance] saveDocument];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }];
    });
}

@end
