//
//  MediaItem.m
//  flickrShare
//
//  Created by master on 11/14/12.
//  Copyright (c) 2012 master. All rights reserved.
//

#import "MediaItem.h"

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
    item.fileName = [element childNamed:@"title"].value;
    item.author = [[element childNamed:@"author"]childNamed:@"name"].value;
   
    SMXMLElement* linkElement = [element childWithAttribute:@"type" value:@"image/jpeg"];
    NSString* urlString =[linkElement attributeNamed:@"href"];
    item.url    = [NSURL URLWithString:    urlString];
    item.published = [element childNamed:@"date.Taken"].value;
    return item;
}



@end
