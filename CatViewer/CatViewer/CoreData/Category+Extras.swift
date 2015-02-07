//
//  Category+Extras.swift
//  CatViewer
//
//  Created by Boolky Bear on 7/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation

extension Category
{
	class func emptyCategoryInContext(context: NSManagedObjectContext) -> Category?
	{
		return context.emptyObjectOfKind("Category") as? Category
	}
	
	class func categoryWithIdentifier(identifier: String?, context: NSManagedObjectContext) -> Category?
	{
		if let identifier = identifier
		{
			return context.objectFromRequestNamed("CategoryWithIdentifier", substitution: ["IDENTIFIER" : identifier], sortDescriptors: nil, error: nil) as? Category
		}
		
		return nil
	}
	
	class func categoryFromModel(model: CategoryModel, context: NSManagedObjectContext) -> Category?
	{
		var category = categoryWithIdentifier(model.identifier, context: context)
		if category == nil
		{
			category = emptyCategoryInContext(context)
			category?.identifier = model.identifier
		}
		
		category?.name = model.name
		
		return category
	}
	
	class func categoriesInContext(context: NSManagedObjectContext) -> [Category]
	{
		if let categories = context.objectsFromRequestNamed("Categories", substitution: [ NSObject : AnyObject ](), sortDescriptors: [ NSSortDescriptor(key: "name", ascending: true) ], error: nil)
		{
			return categories.map {
				$0 as Category
			}
		}
		
		return []
	}
}