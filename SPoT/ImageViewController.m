//
//  ImageViewController.m
//  SPoT
//
//  Created by Marko Tadić on 18.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "ImageViewController.h"
#import "AttributedStringVC.h"
#import "UIApplication+NetworkActivity.h"
#import "DataCacher.h"
#import "MainTabBarController.h"

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (strong, nonatomic) UIPopoverController *urlPopover;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) DataCacher *dataCacher;
@end

@implementation ImageViewController

@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

- (void)setTitle:(NSString *)title
{
    super.title = title;
    self.titleBarButtonItem.title = title;
}

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

- (DataCacher *)dataCacher
{
    if (!_dataCacher) _dataCacher = [[DataCacher alloc] init];
    return _dataCacher;
}

- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        [[[self.splitViewController.viewControllers firstObject] masterPopover] dismissPopoverAnimated:YES];
        
        // fetch the image in another thread
        [self.spinner startAnimating];
        NSURL *imageURL = self.imageURL;
        dispatch_queue_t imageFetchQ = dispatch_queue_create("image downloader", NULL);
        dispatch_async(imageFetchQ, ^{
            
            // if image data is not already cached fetch it from flickr
            NSData *imageData = nil;
            imageData = [self.dataCacher readCacheDataForKey:[imageURL absoluteString]];
            if (!imageData) {
                [[UIApplication sharedApplication] showNetworkActivityIndicator];
                imageData = [[NSData alloc] initWithContentsOfURL:self.imageURL];
                [[UIApplication sharedApplication] hideNetworkActivityIndicator];
                [self.dataCacher writeCacheData:imageData withKey:[imageURL absoluteString]];
            }
            
            UIImage *image = [[UIImage alloc] initWithData:imageData];            
            if (self.imageURL == imageURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) {
                        self.scrollView.contentSize = image.size;
                        self.imageView.image = image;
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                        [self setImageZoom];
                    }
                    [self.spinner stopAnimating];
                });
            }
        });
    }
}

#pragma mark Segues

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"Show URL"]) {
        return (self.imageURL && !self.urlPopover.popoverVisible) ? YES : NO;
    } else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show URL"]) {
        if ([segue.destinationViewController isKindOfClass:[AttributedStringVC class]]) {
            AttributedStringVC *asvc = (AttributedStringVC *)segue.destinationViewController;
            asvc.text = [[NSAttributedString alloc] initWithString:[self.imageURL description]];
            if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
                self.urlPopover = ((UIStoryboardPopoverSegue *)segue).popoverController;
            }
            
        }
    }
}

#pragma mark Set master popover button

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if (barButtonItem) [toolbarItems insertObject:barButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
    _splitViewBarButtonItem = barButtonItem;
}

#pragma mark UIViewcontroller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.scrollView addSubview:self.imageView];
    [self resetImage];
    self.scrollView.delegate = self;
    [self setSplitViewBarButtonItem:self.splitViewBarButtonItem];
    self.titleBarButtonItem.title = self.title;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self setImageZoom];
}

#pragma mark Zooming and centering the image

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // center the image while zooming
    [self centerImageView];
}

- (double)imageMinScale
{
    // get proper scale to show the whole photo
    double widthScale = self.scrollView.bounds.size.width / self.imageView.image.size.width;
    double heightScale = self.scrollView.bounds.size.height / self.imageView.image.size.height;
    return MIN(widthScale, heightScale);
}

- (void)setImageZoom
{
    // set min, max and initial zoom scale
    double minScale = [self imageMinScale];
    if (minScale < DBL_MAX) {
        self.scrollView.minimumZoomScale = minScale;
        self.scrollView.maximumZoomScale = 5.0;
        self.scrollView.zoomScale = minScale;
    }
}

- (void)centerImageView
{
    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
}

@end
