//
//  FlickrPhotoTVC.h
//  SPoT
//
//  Created by Marko Tadić on 18.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//
// Will call setImageURL: as part of any "Show Image" segue.

#import <UIKit/UIKit.h>

@interface FlickrPhotoTVC : UITableViewController

@property (nonatomic, strong) NSArray *photos; // of NSDictionary

@end
