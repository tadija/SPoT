//
//  Photo+Flickr.m
//  SPoT
//
//  Created by Marko Tadić on 28.9.13..
//  Copyright (c) 2013. tadija. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Tag+Create.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    if (photoDictionary) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", photoDictionary[FLICKR_PHOTO_ID]];
        
        NSError *error = nil;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        // if matches is nil or has more than one object, handle error
        if (!matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) { // if it doesnt exists in db, insert it
            photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
            
            // set photo size original if on iPad, large on iPhone
            BOOL iPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
            FlickrPhotoFormat photoSize = (iPad) ? FlickrPhotoFormatOriginal : FlickrPhotoFormatLarge;
            
            photo.unique = [photoDictionary[FLICKR_PHOTO_ID] description];
            photo.title = [photoDictionary[FLICKR_PHOTO_TITLE] description];
            photo.firstLetter = [photo.title substringToIndex:1];
            photo.subtitle = [[photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
            photo.imageURL = [[FlickrFetcher urlForPhoto:photoDictionary format:photoSize] absoluteString];
            photo.thumbnailURL = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
            // along with its tags
            NSMutableSet *tags = [[NSMutableSet alloc] init];
            Tag *allTag = [Tag tagWithName:[Tag allTag] inManagedObjectContext:context];
            [tags addObject:allTag];
            for (NSString *tagName in [[photoDictionary[FLICKR_TAGS] description] componentsSeparatedByString:@" "]) {
                if (![[Tag hiddenTags] containsObject:tagName]) {
                    if (!photo.firstTag) photo.firstTag = tagName;
                }
                Tag *tag = [Tag tagWithName:tagName inManagedObjectContext:context];
                [tags addObject:tag];
            }
            photo.tags = tags;
            
        } else { // if it exists in db, get it
            photo = [matches lastObject];
        }
    }
    
    return photo;
}

@end
