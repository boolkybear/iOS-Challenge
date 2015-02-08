//
//  Rate+Extras.swift
//  CatViewer
//
//  Created by Boolky Bear on 8/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation

extension Rate
{
	class func emptyRateInContext(context: NSManagedObjectContext) -> Rate?
	{
		let rate = context.emptyObjectOfKind("Rate") as? Rate
		
		return rate
	}
	
	class func ratesInContext(context: NSManagedObjectContext) -> [Rate]
	{
		if let rates = context.objectsFromRequestNamed("Rates", substitution: [ NSObject : AnyObject ](), sortDescriptors: [ NSSortDescriptor(key: "rate", ascending: false) ], error: nil)
		{
			return rates.map {
				$0 as Rate
			}
		}
		
		return []
	}
}