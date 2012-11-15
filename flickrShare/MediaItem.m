//
//  MediaItem.m
//  flickrShare
//
//  Created by master on 11/14/12.
//  Copyright (c) 2012 master. All rights reserved.
//

#import "MediaItem.h"
#import "DataManager.h"

@implementation MediaItem
@synthesize thumbnail;
@synthesize fullImage;
@synthesize fileName;
@synthesize author;
@synthesize url;
@synthesize published;

+(MediaItem*) createWithItem:(SMXMLElement*) element   {
    //extracts urls & media info from XML element
    MediaItem* item = [MediaItem new];
    item.thumbnailSaved     = NO;
    item.imageDownloaded    = NO;

    item.author         = [[element childNamed:@"author"]childNamed:@"name"].value;
    item.published      =  [element childNamed:@"date.Taken"].value;
   
    SMXMLElement* linkElement = [element childWithAttribute:@"type" value:@"image/jpeg"];
    NSString* urlString =[linkElement attributeNamed:@"href"];
    item.url            = [NSURL URLWithString:    urlString];
  
    //extract the filename form the URL
    NSArray *filePathComponents = [[item.url absoluteString] pathComponents];
    item.fileName = [filePathComponents objectAtIndex:[filePathComponents count]-1];
  //  NSLog(@"Filename: %@", item.fileName);
    return item;
}


-(BOOL)         saveThumbnailToDocumentsDirectory   {

    
}


-(BOOL)         saveFullImageToDocumentsDirectory   {
    
}



@end
