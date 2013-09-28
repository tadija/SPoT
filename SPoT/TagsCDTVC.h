//
//  TagsCDTVC.h
//  SPoT
//
//  Created by Marko Tadić on 28.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//
// Can do "setTags:" segue and will call said method in destination VC.

#import "CoreDataTableViewController.h"

@interface TagsCDTVC : CoreDataTableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
