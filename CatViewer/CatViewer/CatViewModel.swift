//
//  CatViewModel.swift
//  CatViewer
//
//  Created by Boolky Bear on 8/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation
import UIKit

import Alamofire
import JLToast

enum CatCategory
{
	case AnyCategory
	case NamedCategory(String)
	
	func name() -> String
	{
		switch self
		{
		case .AnyCategory:
			return NSLocalizedString("Any", comment: "Any category")
			
		case .NamedCategory(let name):
			return name
		}
	}
}

enum UpdateField: Int
{
	case UpdateCategory = 0b000001
	case UpdateControls = 0b000010
	case UpdateModel	= 0b000100
	case UpdateProgress = 0b001000
	
	case UpdateAll		= 0b001111
}

typealias UpdateHandler = (Int) -> Void

class CatViewModel
{
	private(set) var currentCategory: CatCategory = .AnyCategory
	private(set) var currentCatModel: CatModel? = nil
	private(set) var currentCat: Cat? = nil
	private(set) var currentCatImage: UIImage? = nil
	
	private(set) var currentProgress: Float = 0.0
	private(set) var shouldEnableControls: Bool = false
	
	private(set) var categories: [CatCategory] = [ .AnyCategory ]
	
	private(set) var updateView: UpdateHandler? = nil
	
	init()
	{
		
	}
	
	func categoryNames() -> [String]
	{
		return self.categories.map { $0.name() }
	}
	
	func catImage() -> UIImage?
	{
		if self.currentCatImage==nil
		{
			if let catImageData = self.currentCatModel?.imageData
			{
				self.currentCatImage = UIImage(data: catImageData)
			}
		}
		
		return self.currentCatImage
	}
	
//	func rateButtonImage() -> UIImage
//	{
//	}
//	
//	func favouriteButtonImage() -> UIImage
//	{
//	}
	
	func sourceUrlText() -> String
	{
		return self.currentCatModel?.sourceUrl ?? ""
	}
	
	func onUpdate(handler: UpdateHandler) -> Self
	{
		handler(UpdateField.UpdateAll.rawValue)
		
		self.updateView = handler
		
		return self
	}
}

// Fetch Helpers
extension CatViewModel
{
	func initializeCategories()
	{
		if let mainContext = AppDelegate.mainContext()
		{
			let categories = Category.categoriesInContext(mainContext)
			if countElements(categories) == 0
			{
				fetchCategories()
			}
		}
	}
	
	func fetchCategories()
	{
		JLToast.makeText(NSLocalizedString("Fetching categories on first launch", comment: "Fetch categories")).show()
		
		self.currentProgress = 0.0
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		
		Alamofire.request(Alamofire.Method.GET, "http://thecatapi.com/api/categories/list")
			.validate()
			.progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
				dispatch_async(dispatch_get_main_queue()) {
					self.currentProgress = Float(totalBytesExpectedToRead) == 0.0 ? 0.0 : Float(totalBytesRead)/Float(totalBytesExpectedToRead)
					
					self.updateView?(UpdateField.UpdateProgress.rawValue)
				}
				
				return
			}
			.response { (request, _, xmlData, error) in
				if let xmlData = xmlData as? NSData
				{
					if xmlData.length > 0 && error == nil
					{
						if !self.parseCategoriesFromXmlData(xmlData)
						{
							// TODO: log error
							JLToast.makeText(NSLocalizedString("Error saving categories", comment: "Fetching categories")).show()
						}
					}
				}
				
				dispatch_async(dispatch_get_main_queue()) {
					self.currentProgress = 0.0
					UIApplication.sharedApplication().networkActivityIndicatorVisible = false
					
					self.updateView?(UpdateField.UpdateProgress.rawValue)
				}
		}
	}
	
	func parseCategoriesFromXmlData(xmlData: NSData) -> Bool
	{
		var hasErrors = false
		
		let parser = NSXMLParser(data: xmlData)
		let categoryDelegate = CategoryParserDelegate()
		
		parser.delegate = categoryDelegate
		if (parser.parse() && categoryDelegate.isParsed())
		{
			dispatch_async(dispatch_get_main_queue()) {
				if let mainContext = AppDelegate.mainContext()
				{
					for i in 0..<categoryDelegate.count()
					{
						let category = Category.categoryFromModel(categoryDelegate[i], context: mainContext)
						
						hasErrors = category == nil || hasErrors
					}
					
					hasErrors = !mainContext.save(nil) || hasErrors
				}
				
				return
			}
		}
		else
		{
			hasErrors = true
		}
		
		return hasErrors
	}
	
	func fetchCat()
	{
		self.resetValues()
		self.updateView?(UpdateField.UpdateAll.rawValue)
		
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		
		var requestParameters = [ "format" : "xml" ]
		switch self.currentCategory
		{
		case .AnyCategory:
			break
			
		case .NamedCategory(_):
			requestParameters[ "category" ] = self.currentCategory.name()
		}

		Alamofire.request(Alamofire.Method.GET, "http://thecatapi.com/api/images/get", parameters: requestParameters)
			.validate()
			.response { (request, _, xmlData, error) in
				
				if let xmlData = xmlData as? NSData
				{
					if xmlData.length > 0 && error == nil
					{
						if !self.parseCatFromXmlData(xmlData)
						{
							// TODO: log error
							JLToast.makeText(NSLocalizedString("Error fetching cat", comment: "Fetching cat")).show()
						}
						else
						{
							dispatch_async(dispatch_get_main_queue()) {
								self.updateView?(UpdateField.UpdateAll.rawValue)
								
								return
							}
							// TODO: download cat image
						}
					}
				}
				
				// TODO: check errors
		}
		
	}
	
	func resetValues()
	{
		self.currentCatModel = nil
		self.currentCat = nil
		self.currentCatImage = nil
		
		self.currentProgress = 0.0
		self.shouldEnableControls = false
	}
	
	func parseCatFromXmlData(xmlData: NSData) -> Bool
	{
		var hasErrors = false
		
		let parser = NSXMLParser(data: xmlData)
		let catDelegate = CatParserDelegate()
		
		parser.delegate = catDelegate
		if (parser.parse() && catDelegate.isParsed() && catDelegate.count() == 1)
		{
			self.currentCatModel = catDelegate[0]
		}
		else
		{
			hasErrors = true
		}
		
		return hasErrors
	}
}