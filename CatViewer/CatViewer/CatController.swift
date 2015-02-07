//
//  CatController.swift
//  CatViewer
//
//  Created by Boolky Bear on 4/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import UIKit

import AlamoFire
import JLToast

class CatController: UIViewController {
	
	enum CatCategory
	{
		case AnyCategory
		case NamedCategory(String)
	}

	@IBOutlet var downloadProgress: UIProgressView!
	@IBOutlet var categoryButton: UIButton!
	
	@IBOutlet var catImageView: UIImageView!
	@IBOutlet var rateButton: UIButton!
	@IBOutlet var favouriteButton: UIButton!
	@IBOutlet var nextButton: UIButton!
	
	@IBOutlet var urlTextField: UITextField!
	
	var currentCat: CatModel? = nil
	var currentCategory: CatCategory = .AnyCategory
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		initializeCategories()
		fetchCat()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// Actions
extension CatController
{
	@IBAction func categoryButtonTouched(sender: AnyObject) {
		let categoryController = UIAlertController(title: NSLocalizedString("Choose category", comment: "Category chooser title"), message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
		categoryController.addAction(UIAlertAction(title: NSLocalizedString("Any", comment: ""), style: UIAlertActionStyle.Cancel, handler: {
			alertAction in
			self.currentCategory = .AnyCategory
			self.categoryButton?.setTitle(NSLocalizedString("Any", comment: ""), forState: .Normal)
			self.fetchCat()
		}))
		
		let categories = Category.categoriesInContext(AppDelegate.mainContext()!)
		categories.map {
			category in
			categoryController.addAction(UIAlertAction(title: category.name!, style: UIAlertActionStyle.Default, handler: {
				alertAction in
				self.currentCategory = .NamedCategory(category.name!)
				self.categoryButton?.setTitle(category.name!, forState: .Normal)
				self.fetchCat()
				
				return
			}))
		}
		
		self.presentViewController(categoryController, animated: true, completion: nil)
	}
	
	@IBAction func copyUrlButtonTouched(sender: AnyObject) {
		if let sourceUrl = self.currentCat?.sourceUrl
		{
			UIPasteboard.generalPasteboard().string = sourceUrl
			JLToast.makeText(NSLocalizedString("Copied to pasteboard", comment: "URL copy to pasteboard"), duration: JLToastDelay.ShortDelay).show()
		}
	}
	
	@IBAction func favouriteButtonTouched(sender: AnyObject) {
		if let mainContext = AppDelegate.mainContext()
		{
			var cat = Cat.catWithIdentifier(currentCat?.identifier, context: mainContext)
			if cat == nil
			{
				cat = Cat.catFromModel(self.currentCat!, context: mainContext)
			}
			
			if let favourite = cat?.favourite
			{
				mainContext.deleteObject(favourite)
			}
			else
			{
				let favourite = Favourite.favouriteInContext(mainContext)
				cat?.favourite = favourite
			}
			
			if !mainContext.save(nil)
			{
				// TODO: log error
			}
		}
	}
	
	@IBAction func nextButtonTouched(sender: AnyObject) {
		fetchCat()
	}
}

// Helpers
extension CatController
{
	func fetchCategories()
	{
		self.downloadProgress?.progress = 0.0
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		
		Alamofire.request(Alamofire.Method.GET, "http://thecatapi.com/api/categories/list")
			.validate()
			.progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
				dispatch_async(dispatch_get_main_queue()) {
					self.downloadProgress?.progress = Float(totalBytesExpectedToRead) == 0.0 ? 0.0 : Float(totalBytesRead)/Float(totalBytesExpectedToRead)
					
					return
				}
				
				return
			}
			.response { (request, _, xmlData, error) in
				if let xmlData = xmlData as? NSData
				{
					if xmlData.length > 0 && error == nil
					{
						let parser = NSXMLParser(data: xmlData)
						let categoryDelegate = CategoryParserDelegate()
						
						parser.delegate = categoryDelegate
						if (parser.parse() && categoryDelegate.isParsed())
						{
							dispatch_async(dispatch_get_main_queue()) {
								if let mainContext = AppDelegate.mainContext()
								{
									var hasErrors = false
									for i in 0..<categoryDelegate.count()
									{
										let category = Category.categoryFromModel(categoryDelegate[i], context: mainContext)
										if category == nil
										{
											hasErrors = true
										}
									}
									
									if mainContext.save(nil) == false
									{
										hasErrors = true
									}
									
									if hasErrors
									{
										// TODO: log error
										JLToast.makeText(NSLocalizedString("Error saving categories", comment: "Fetching categories")).show()
									}
								}
								
								return
							}
						}
					}
				}
				
				dispatch_async(dispatch_get_main_queue()) {
					self.downloadProgress?.progress = 0.0
					UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				}
		}
	}
	
	func fetchCat()
	{
		self.downloadProgress?.progress = 0.0
		self.catImageView?.image = nil
		
		self.enableUI(false)
		
		var parameters = [ "format" : "xml" ]
		switch currentCategory
		{
		case .AnyCategory:
			break
			
		case .NamedCategory(let categoryName):
			parameters["category"] = categoryName
		}
		Alamofire.request(Alamofire.Method.GET, "http://thecatapi.com/api/images/get", parameters: parameters)
			.validate()
			.response { (request, _, xmlData, error) in
				
				var willEnableUI = false
				
				if let xmlData = xmlData as? NSData
				{
					if xmlData.length > 0 && error == nil
					{
						let parser = NSXMLParser(data: xmlData)
						let catDelegate = CatParserDelegate()
						
						parser.delegate = catDelegate
						if (parser.parse() && catDelegate.isParsed() && catDelegate.count() == 1)
						{
							self.currentCat = catDelegate[0]
							
							dispatch_async(dispatch_get_main_queue()) {
								self.urlTextField?.text = self.currentCat?.sourceUrl ?? ""
								
								return
							}
							
							if let catImageUrl = self.currentCat?.url
							{
								dispatch_async(dispatch_get_main_queue()) {
									UIApplication.sharedApplication().networkActivityIndicatorVisible = true
									
									return
								}
								willEnableUI = true
								Alamofire.request(Alamofire.Method.GET, catImageUrl, parameters: [ "format" : "xml" ])
									.validate()
									.progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
										dispatch_async(dispatch_get_main_queue()) {
											self.downloadProgress?.progress = Float(totalBytesExpectedToRead) == 0.0 ? 0.0 : Float(totalBytesRead)/Float(totalBytesExpectedToRead)
											
											return
										}
										
										return
									}
									.response { (request, _, xmlData, error) in
										if let xmlData = xmlData as? NSData
										{
											self.currentCat?.imageData = xmlData
											if let image = UIImage(data: xmlData)
											{
												dispatch_async(dispatch_get_main_queue()) {
													self.catImageView?.image = image
													
													return
												}
											}
										}
										
										dispatch_async(dispatch_get_main_queue()) {
											self.downloadProgress?.progress = 0.0
											UIApplication.sharedApplication().networkActivityIndicatorVisible = false
											
											self.enableUI(true)
										}
									}
							}
						}
					}
				}
				
				if willEnableUI == false
				{
					self.enableUI(true)
				}
			}
		
	}
	
	func enableUI(enabled: Bool)
	{
		self.rateButton?.enabled = enabled
		self.favouriteButton?.enabled = enabled
		self.nextButton?.enabled = enabled
	}
	
	func initializeCategories()
	{
		if let mainContext = AppDelegate.mainContext()
		{
			if let categories = mainContext.objectsFromRequestNamed("Categories", substitution: [NSObject : AnyObject](), sortDescriptors: nil, error: nil)
			{
				if countElements(categories) == 0
				{
					fetchCategories()
				}
			}
			else
			{
				fetchCategories()
			}
		}
	}
}
