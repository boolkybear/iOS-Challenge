//
//  Favourite+Extras.swift
//  CatViewer
//
//  Created by Boolky Bear on 7/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation

extension Favourite
{
	class func favouriteInContext(context: NSManagedObjectContext) -> Favourite?
	{
		let favourite = context.emptyObjectOfKind("Favourite") as? Favourite
		
		favourite?.date = NSDate()
		
		return favourite
	}
}