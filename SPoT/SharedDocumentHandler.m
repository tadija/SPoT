//
//  SharedDocumentHandler.m
//  SPoT
//
//  Created by Marko Tadić on 28.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "SharedDocumentHandler.h"

@implementation SharedDocumentHandler

static SharedDocumentHandler *_sharedInstance;

+ (SharedDocumentHandler *)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Shared Document"];
        self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    
    return self;
}

- (void)saveDocument
{
    [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:nil];    
}

@end
