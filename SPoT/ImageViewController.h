//
//  ImageViewController.h
//  SPoT
//
//  Created by Marko Tadić on 18.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface ImageViewController : UIViewController <SplitViewBarButtonItemPresenter>

@property (nonatomic, strong) NSURL *imageURL;

@end
