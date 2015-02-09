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

typealias UpdateHandler = (CatViewModel, Int) -> Void

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
		initializeCategories()
		fetchCat()
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
	
	func rateButtonImage() -> UIImage
	{
		return UIImage(named: self.currentCat?.rate == nil ? "staroutline" : "starfilled")!
	}
	
	func favouriteButtonImage() -> UIImage
	{
		return UIImage(named: self.currentCat?.favourite == nil ? "heartoutline" : "heartfilled")!
	}
	
	func sourceUrlText() -> String
	{
		return self.currentCatModel?.sourceUrl ?? ""
	}
	
	func onUpdate(handler: UpdateHandler) -> Self
	{
		handler(self, UpdateField.UpdateAll.rawValue)
		
		self.updateView = handler
		
		return self
	}
	
	// Setters
	func setCategory(category: CatCategory)
	{
		self.currentCategory = category
		
		self.updateView?(self, UpdateField.UpdateCategory.rawValue)
		
		fetchCat()
	}
	
	func toggleFavourite()
	{
		if let mainContext = AppDelegate.mainContext()
		{
			if self.currentCat == nil
			{
				self.currentCat = Cat.catWithIdentifier(self.currentCatModel?.identifier, context: mainContext) ??
					Cat.catFromModel(self.currentCatModel!, context: mainContext)
			}
			
			if let favourite = self.currentCat?.favourite
			{
				mainContext.deleteObject(favourite)
			}
			else
			{
				let favourite = Favourite.favouriteInContext(mainContext)
				self.currentCat?.favourite = favourite
			}
			
			if !mainContext.save(nil)
			{
				// TODO: log error
				JLToast.makeText(NSLocalizedString("Error saving favourite", comment: "DB Error")).show()
			}
			
			self.updateView?(self, UpdateField.UpdateControls.rawValue)
		}
	}
	
	func rate(rate: Int)
	{
		if let mainContext = AppDelegate.mainContext()
		{
			if self.currentCat == nil
			{
				self.currentCat = Cat.catWithIdentifier(self.currentCatModel?.identifier, context: mainContext) ??
					Cat.catFromModel(self.currentCatModel!, context: mainContext)
			}
			
			var rating = self.currentCat?.rate ?? Rate.emptyRateInContext(mainContext)
			
			rating?.rate = rate
			rating?.cat = self.currentCat
			
			if !mainContext.save(nil)
			{
				// TODO: log error
				JLToast.makeText(NSLocalizedString("Error saving rating", comment: "DB Error")).show()
			}
			
			self.updateView?(self, UpdateField.UpdateControls.rawValue)
		}
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
			else
			{
				for category in categories
				{
					self.categories.append(.NamedCategory(category.name ?? ""))
				}
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
					
					self.updateView?(self, UpdateField.UpdateProgress.rawValue)
				}
				
				return
			}
			.response { (request, _, xmlData, error) in
				if let xmlData = xmlData as? NSData
				{
					if xmlData.length > 0 && error == nil
					{
						self.parseCategoriesFromXmlData(xmlData)
					}
				}
				
				dispatch_async(dispatch_get_main_queue()) {
					self.currentProgress = 0.0
					UIApplication.sharedApplication().networkActivityIndicatorVisible = false
					
					self.updateView?(self, UpdateField.UpdateProgress.rawValue)
				}
		}
	}
	
	func parseCategoriesFromXmlData(xmlData: NSData)
	{
		let parser = NSXMLParser(data: xmlData)
		let categoryDelegate = CategoryParserDelegate()
		
		var hasErrors = false
		
		parser.delegate = categoryDelegate
		if (parser.parse() && categoryDelegate.isParsed())
		{
			dispatch_async(dispatch_get_main_queue()) {
				if let mainContext = AppDelegate.mainContext()
				{
					for i in 0..<categoryDelegate.count()
					{
						let categoryModel = categoryDelegate[i]
						
						self.categories.append(CatCategory.NamedCategory(categoryModel.name ?? ""))
						let category = Category.categoryFromModel(categoryModel, context: mainContext)
						
						hasErrors = category == nil || hasErrors
					}
					
					hasErrors = !mainContext.save(nil) || hasErrors
					
					if hasErrors
					{
						// TODO: log error
						JLToast.makeText(NSLocalizedString("Error saving categories", comment: "Fetching categories")).show()
					}
					else
					{
						self.updateView?(self, UpdateField.UpdateCategory.rawValue)
					}
				}
				
				return
			}
		}
	}
	
	func fetchCat()
	{
		self.resetValues()
		self.updateView?(self, UpdateField.UpdateAll.rawValue)
		
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
						self.parseCatFromXmlData(xmlData)
						dispatch_async(dispatch_get_main_queue()) {
							self.updateView?(self, UpdateField.UpdateAll.rawValue)
							
							return
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
	
	func parseCatFromXmlData(xmlData: NSData)
	{
		var hasErrors = false
		
		let parser = NSXMLParser(data: xmlData)
		let catDelegate = CatParserDelegate()
		
		parser.delegate = catDelegate
		if (parser.parse() && catDelegate.isParsed() && catDelegate.count() == 1)
		{
			self.currentCatModel = catDelegate[0]
			self.downloadImageFromCatModel()
		}
		else
		{
			hasErrors = true
		}
		
		if hasErrors
		{
			// TODO: log error
			JLToast.makeText(NSLocalizedString("Error downloading cat", comment: "Fetching cat")).show()
			
			self.shouldEnableControls = true
			self.updateView?(self, UpdateField.UpdateControls.rawValue)
		}
		else
		{
			self.updateView?(self, UpdateField.UpdateModel.rawValue)
		}
	}
	
	func downloadImageFromCatModel()
	{
		if let catImageUrl = self.currentCatModel?.url
		{
			dispatch_async(dispatch_get_main_queue()) {
				UIApplication.sharedApplication().networkActivityIndicatorVisible = true
				
				return
			}
			
			Alamofire.request(Alamofire.Method.GET, catImageUrl)
				.validate()
				.progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
					dispatch_async(dispatch_get_main_queue()) {
						self.currentProgress = Float(totalBytesExpectedToRead) == 0.0 ? 0.0 : Float(totalBytesRead)/Float(totalBytesExpectedToRead)
						
						self.updateView?(self, UpdateField.UpdateProgress.rawValue)
					}
					
					return
				}
				.response { (request, _, imageData, error) in
					self.currentCatModel?.imageData = imageData as? NSData
					
					dispatch_async(dispatch_get_main_queue()) {
						self.currentProgress = 0.0
						self.shouldEnableControls = true
						
						self.updateView?(self, UpdateField.UpdateAll.rawValue)
						
						UIApplication.sharedApplication().networkActivityIndicatorVisible = false
					}
			}
		}
	}
}