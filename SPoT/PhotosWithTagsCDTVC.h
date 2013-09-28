//
//  PhotosWithTagsCDTVC.h
//  SPoT
//
//  Created by Marko Tadić on 28.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "PhotosCDTVC.h"
#import "Tag.h"

@interface PhotosWithTagsCDTVC : PhotosCDTVC

@property (nonatomic, strong) Tag *tag;

@end
