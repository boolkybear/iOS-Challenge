//
//  Cat+Extras.swift
//  CatViewer
//
//  Created by Boolky Bear on 7/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation

extension Cat
{
	class func emptyCatInContext(context: NSManagedObjectContext) -> Cat?
	{
		return context.emptyObjectOfKind("Cat") as? Cat
	}
	
	class func catWithIdentifier(identifier: String?, context: NSManagedObjectContext) -> Cat?
	{
		if let identifier = identifier
		{
			return context.objectFromRequestNamed("CatWithIdentifier", substitution: ["IDENTIFIER" : identifier], sortDescriptors: nil, error: nil) as? Cat
		}
		
		return nil
	}
	
	class func catFromModel(model: CatModel, context: NSManagedObjectContext) -> Cat?
	{
		var cat = catWithIdentifier(model.identifier, context: context)
		if cat == nil
		{
			cat = emptyCatInContext(context)
			cat?.identifier = model.identifier
		}
		
		cat?.url = model.url
		cat?.sourceUrl = model.sourceUrl
		
		return cat
	}
}