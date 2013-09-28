//
//  DataCacher.m
//  SPoT
//
//  Created by Marko Tadić on 25.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "DataCacher.h"

@interface DataCacher()
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSURL *cachePath;
@property (nonatomic, strong) NSDictionary *cacheMetadata;

- (void)limitCacheSize;
@end

@implementation DataCacher

#pragma mark Properties

@synthesize cacheMetadata = _cacheMetadata;

- (NSFileManager *)fileManager
{
    if (!_fileManager) _fileManager = [[NSFileManager alloc] init];
    return _fileManager;
}

#define CACHE_FOLDER_NAME @"flickr_images"
- (NSURL *)cachePath
{
    if (!_cachePath) {
        NSURL *cacheFolder = [[self.fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *cachePath = [cacheFolder URLByAppendingPathComponent:CACHE_FOLDER_NAME];
        NSError *error = nil;
        if (![self.fileManager fileExistsAtPath:[cachePath path]]) {
            [self.fileManager createDirectoryAtURL:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        _cachePath = (!error) ? cachePath : nil;
    }
    return _cachePath;
}

#define CACHE_METADATA_FILENAME @"flickr_images.metadata"
- (NSDictionary *)cacheMetadata
{
    if (!_cacheMetadata) {
        NSURL *cacheMetadataPath = [self.cachePath URLByAppendingPathComponent:CACHE_METADATA_FILENAME];
        if ([self.fileManager fileExistsAtPath:[cacheMetadataPath path]]) {
            _cacheMetadata = [[NSDictionary alloc] initWithContentsOfURL:cacheMetadataPath];
        } else {
            _cacheMetadata = [[NSDictionary alloc] init];
        }
    }
    return _cacheMetadata;
}

- (void)setCacheMetadata:(NSDictionary *)cacheMetadata
{
    _cacheMetadata = cacheMetadata;
    // write cache metadata to file
    NSURL *cacheMetadataPath = [self.cachePath URLByAppendingPathComponent:CACHE_METADATA_FILENAME];
    [cacheMetadata writeToURL:cacheMetadataPath atomically:YES];
}

#pragma mark Caching logic

- (void)writeCacheData:(NSData *)data withKey:(NSString *)key
{
    if (key) {
        // create filename for cached data and save it to cache folder
        NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@":/\\?%*|\"<>"];
        NSString *fileName = [[key componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
        NSURL *dataURL = [self.cachePath URLByAppendingPathComponent:fileName];
        [data writeToURL:dataURL atomically:YES];
        
        // delete old cache data
        [self limitCacheSize];
        
        // save metadata for this cache
        NSMutableDictionary *completeCacheMetadata = [self.cacheMetadata mutableCopy];
        completeCacheMetadata[key] = [dataURL absoluteString];
        self.cacheMetadata = completeCacheMetadata;
    }
}

- (NSData *)readCacheDataForKey:(NSString *)key
{
    NSData *data = nil;
    
    if (key) {
        NSURL *dataURL = [NSURL URLWithString:self.cacheMetadata[key]];
        // if there is cache data for this key, get it, touch it, give it
        if ([self.fileManager fileExistsAtPath:[dataURL path]]) {
            data = [[NSData alloc] initWithContentsOfURL:dataURL];
            [self.fileManager setAttributes:@{NSFileModificationDate : [NSDate date]} ofItemAtPath:[dataURL path] error:nil];
        }
    }
    
    return data;
}

#define IPHONE_CACHE_SIZE 1024*1024*5
#define IPAD_CACHE_SIZE 1024*1024*10
- (void)limitCacheSize
{
    NSDirectoryEnumerator *dirEnum = [self.fileManager enumeratorAtURL:self.cachePath
                                            includingPropertiesForKeys:@[NSURLFileSizeKey, NSURLAttributeModificationDateKey]
                                                               options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
    // get all cached files and their details
    NSMutableArray *files = [[NSMutableArray alloc] init];
    __block NSUInteger folderSize = 0;
    NSNumber *fileSize;
    NSDate *fileDate;
    
    for (NSURL *url in dirEnum) {
        [url getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        [url getResourceValue:&fileDate forKey:NSURLAttributeModificationDateKey error:nil];
        [files addObject:@{@"url" : url, @"fileSize" : fileSize, @"fileDate" : fileDate}];
        folderSize += [fileSize integerValue];
    }
    
    // set cache size based on device
    BOOL iPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    NSUInteger cacheSize = (iPad) ? IPAD_CACHE_SIZE : IPHONE_CACHE_SIZE;
    
    // delete old cache files to reach the max allowed cache size
    if (folderSize > cacheSize) {
        NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"fileDate" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByDate];
        NSArray *sortedFiles = [files sortedArrayUsingDescriptors:sortDescriptors];
        
        [sortedFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            folderSize -= [obj[@"fileSize"] integerValue];
            [self.fileManager removeItemAtURL:obj[@"url"] error:nil];
            *stop = folderSize < cacheSize;
        }];
    }
}

- (void)clearCache
{
    NSDirectoryEnumerator *dirEnum = [self.fileManager enumeratorAtURL:self.cachePath includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
    
    // delete all cache files
    for (NSURL *url in dirEnum) {
        [self.fileManager removeItemAtURL:url error:nil];
    }
    
    // reset cache metadata
    self.cacheMetadata = nil;
}

@end
