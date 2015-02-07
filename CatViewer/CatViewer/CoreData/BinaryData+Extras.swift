//
//  BinaryData+Extras.swift
//  CatViewer
//
//  Created by Boolky Bear on 7/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation

extension BinaryData
{
	class func emptyBinaryDataInContext(context: NSManagedObjectContext) -> BinaryData?
	{
		let binaryData = context.emptyObjectOfKind("BinaryData") as? BinaryData
		
		return binaryData
	}
}