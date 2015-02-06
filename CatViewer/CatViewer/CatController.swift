//
//  CatController.swift
//  CatViewer
//
//  Created by Boolky Bear on 4/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import UIKit

import AlamoFire

class CatController: UIViewController {

	@IBOutlet var downloadProgress: UIProgressView!
	@IBOutlet var categoryButton: UIButton!
	
	@IBOutlet var catImageView: UIImageView!
	@IBOutlet var rateButton: UIButton!
	@IBOutlet var favouriteButton: UIButton!
	
	@IBOutlet var urlTextField: UITextField!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.catImageView?.layer.cornerRadius = 150.0
		self.catImageView?.layer.masksToBounds = true

        // Do any additional setup after loading the view.
		fetchCategories()
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
	}
	
	@IBAction func copyUrlButtonTouched(sender: AnyObject) {
	}
	
	@IBAction func nextButtonTouched(sender: AnyObject) {
		fetchCat()
	}
}

// Helpers
extension CatController
{
	func fetchCategories() -> [CategoryModel]
	{
		var categories = [CategoryModel]()
		
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
							for i in 0..<categoryDelegate.count()
							{
								categories.append(categoryDelegate[i])
							}
						}
					}
				}
				
				dispatch_async(dispatch_get_main_queue()) {
					self.downloadProgress?.progress = 0.0
					UIApplication.sharedApplication().networkActivityIndicatorVisible = false
				}
		}
		
		return categories
	}
	
	func fetchCat()
	{
		self.downloadProgress?.progress = 0.0
		
		Alamofire.request(Alamofire.Method.GET, "http://thecatapi.com/api/images/get", parameters: [ "format" : "xml" ])
			.validate()
			.response { (request, _, xmlData, error) in
				if let xmlData = xmlData as? NSData
				{
					if xmlData.length > 0 && error == nil
					{
						let parser = NSXMLParser(data: xmlData)
						let catDelegate = CatParserDelegate()
						
						parser.delegate = catDelegate
						if (parser.parse() && catDelegate.isParsed() && catDelegate.count() == 1)
						{
							let cat = catDelegate[0]
							
							dispatch_async(dispatch_get_main_queue()) {
								self.urlTextField?.text = cat.sourceUrl ?? ""
								
								return
							}
							
							if let catImageUrl = cat.url
							{
								dispatch_async(dispatch_get_main_queue()) {
									UIApplication.sharedApplication().networkActivityIndicatorVisible = true
									
									return
								}
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
										}
									}
							}
						}
					}
				}
			}
		
	}
}
