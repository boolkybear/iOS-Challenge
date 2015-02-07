//
//  NSManagedObjectContext+misc.h
//  ByBCoreData
//
//  Created by Boolky Bear on 11/05/13.
//  Copyright (c) 2013 ByBDesigns. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (misc)

- (id) emptyObjectOfKind:(NSString *)_type;

- (NSArray *) objectsFromRequestNamed:(NSString *)_request substitution:(NSDictionary *)_paramDict sortDescriptors:(NSArray *)_sortDescriptors error:(NSError **)_error;

- (NSManagedObject *) objectFromRequestNamed:(NSString *)_request substitution:(NSDictionary *)_paramDict sortDescriptors:(NSArray *)_sortDescriptors error:(NSError **)_error;

- (NSManagedObjectModel *) managedObjectModel;

@end
