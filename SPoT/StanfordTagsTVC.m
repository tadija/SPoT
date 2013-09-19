//
//  StanfordTagsTVC.m
//  SPoT
//
//  Created by Marko Tadić on 20.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "StanfordTagsTVC.h"
#import "FlickrFetcher.h"

@implementation StanfordTagsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.photos = [FlickrFetcher stanfordPhotos];
}

@end
