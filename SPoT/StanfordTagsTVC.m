//
//  StanfordTagsTVC.m
//  SPoT
//
//  Created by Marko Tadić on 20.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "StanfordTagsTVC.h"
#import "FlickrFetcher.h"
#import "UIApplication+NetworkActivity.h"

@implementation StanfordTagsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadStanfordPhotosFromFlickr];
    [self.refreshControl addTarget:self action:@selector(loadStanfordPhotosFromFlickr) forControlEvents:UIControlEventValueChanged];
}

- (void)loadStanfordPhotosFromFlickr
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t loaderQ = dispatch_queue_create("stanford photos loader", NULL);
    dispatch_async(loaderQ, ^{
        [[UIApplication sharedApplication] showNetworkActivityIndicator];
        NSArray *stanfordPhotos = [FlickrFetcher stanfordPhotos];
        [[UIApplication sharedApplication] hideNetworkActivityIndicator];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = stanfordPhotos;
            [self.refreshControl endRefreshing];
        });
    });
}

@end
