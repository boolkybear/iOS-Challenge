//
//  Cat+Extras.swift
//  CatViewer
//
//  Created by Boolky Bear on 7/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation
import ImageIO
import UIKit

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
		var cat = catWithIdentifier(model.identifier, context: context) ?? emptyCatInContext(context)

		cat?.identifier = model.identifier
		cat?.url = model.url
		cat?.sourceUrl = model.sourceUrl
		
		var imageBinaryData = cat?.picture ?? BinaryData.emptyBinaryDataInContext(context)
		cat?.picture = imageBinaryData
		
		imageBinaryData?.url = model.url
		imageBinaryData?.data = model.imageData
		
		if let imageData = model.imageData
		{
			if let imageSource = CGImageSourceCreateWithData(imageData, nil)
			{
				let options = [
					String(kCGImageSourceThumbnailMaxPixelSize): 72.0,
					String(kCGImageSourceCreateThumbnailFromImageIfAbsent): true
				]
				
				let thumbnailImage = UIImage(CGImage: CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options))
				let thumbnailData = UIImageJPEGRepresentation(thumbnailImage, 0.75)
				
				var thumbnailBinaryData = cat?.thumbnail ?? BinaryData.emptyBinaryDataInContext(context)
				cat?.thumbnail = thumbnailBinaryData

				thumbnailBinaryData?.url = cat?.url
				thumbnailBinaryData?.data = thumbnailData
			}
		}
		
		return cat
	}
}