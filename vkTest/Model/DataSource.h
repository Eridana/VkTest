//
//  DataSource.h
//  vkTest
//
//  Created by Женя Михайлова on 08.09.15.
//  Copyright (c) 2015 jane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData+MagicalRecord.h>

@interface DataSource : NSObject <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
- (void)setupFetchResultsControllerWithRequest:(NSFetchRequest*)request;

@end
