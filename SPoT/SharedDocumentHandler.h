//
//  SharedDocumentHandler.h
//  SPoT
//
//  Created by Marko Tadić on 28.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedDocumentHandler : NSObject

@property (nonatomic, strong) UIManagedDocument *document;

+ (SharedDocumentHandler *)sharedInstance;
- (void)saveDocument;

@end
