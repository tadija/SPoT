//
//  DataCacher.h
//  SPoT
//
//  Created by Marko Tadić on 25.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataCacher : NSObject

- (void)writeCacheData:(NSData *)data withKey:(NSString *)key;
- (NSData *)readCacheDataForKey:(NSString *)key;
- (void)clearCache;

@end
