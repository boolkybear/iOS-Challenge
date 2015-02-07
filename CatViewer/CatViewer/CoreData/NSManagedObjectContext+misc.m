//
//  NSManagedObjectContext+misc.m
//  ByBCoreData
//
//  Created by Boolky Bear on 11/05/13.
//  Copyright (c) 2013 ByBDesigns. All rights reserved.
//

#import "NSManagedObjectContext+misc.h"

@implementation NSManagedObjectContext (misc)

- (id) emptyObjectOfKind:(NSString *)_type
{
	NSEntityDescription *entDesc = [NSEntityDescription entityForName:_type inManagedObjectContext:self];
	Class objClass = NSClassFromString([entDesc managedObjectClassName]);
	
	id dev = [[objClass alloc] initWithEntity:entDesc insertIntoManagedObjectContext:self];
	
	return dev;
}

- (NSArray *) objectsFromRequestNamed:(NSString *)_request substitution:(NSDictionary *)_paramDict sortDescriptors:(NSArray *)_sortDescriptors error:(NSError **)_error
{
	NSArray *dev = nil;
	
	NSManagedObjectModel *model = [self managedObjectModel];
	NSFetchRequest *request = [model fetchRequestFromTemplateWithName:_request substitutionVariables:_paramDict];
	if(_sortDescriptors!=nil)
		[request setSortDescriptors:_sortDescriptors];
	
	dev = [self executeFetchRequest:request error:_error];
	
	return dev;
}

- (NSManagedObject *) objectFromRequestNamed:(NSString *)_request substitution:(NSDictionary *)_paramDict sortDescriptors:(NSArray *)_sortDescriptors error:(NSError **)_error
{
	NSArray *result = [self objectsFromRequestNamed:_request substitution:_paramDict sortDescriptors:_sortDescriptors error:_error];
	
	return [result lastObject];
}

- (NSManagedObjectModel *) managedObjectModel
{
	return [[self persistentStoreCoordinator] managedObjectModel];
}

@end
