//
//  DataSource.m
//  vkTest
//
//  Created by Женя Михайлова on 08.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import "DataSource.h"

@implementation DataSource

- (void)setupFetchResultsControllerWithRequest:(NSFetchRequest*)request {
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:[NSManagedObjectContext MR_defaultContext]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    if (!self.fetchedResultsController.delegate) {
        self.fetchedResultsController.delegate = self;
    }
    
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error in Data Source %@, %@", error, [error userInfo]);
        abort();
    }
}

@end
