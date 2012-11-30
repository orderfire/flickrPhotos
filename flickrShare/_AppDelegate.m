//
//  _AppDelegate.m
//  flickrShare
//
//  Created by master on 11/14/12.
//  Copyright (c) 2012 master. All rights reserved.
//

#import "_AppDelegate.h"
#import "SyncManager.h"
#import "DataManager.h"


@implementation _AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DataManager createDirectoryStructureInDocuments];
    [[SyncManager sharedInstance] downloadFlickrPhotos];    //created syncmanager as delegate so the sync isn't tied to the viewcontroller (when it appears).  Was planning on using this class in another project
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
