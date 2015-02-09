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

	@IBOutlet var downloadProgress: UIProgressView!
	@IBOutlet var categoryButton: UIButton!
	
	@IBOutlet var catImageView: UIImageView!
	@IBOutlet var rateButton: UIButton!
	@IBOutlet var favouriteButton: UIButton!
	@IBOutlet var nextButton: UIButton!
	@IBOutlet var zoomButton: UIButton!
	
	@IBOutlet var urlTextField: UITextField!
	@IBOutlet var copyButton: UIButton!
	
	var currentCat: CatModel? = nil
	var currentCategory: CatCategory = .AnyCategory
	
	var catViewModel: CatViewModel? = nil
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.catViewModel = CatViewModel().onUpdate(updateFields)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		
		if segue.identifier == "ViewerPushSegue"
		{
			let viewerController = segue.destinationViewController as ViewerController
			viewerController.catModel = self.catViewModel?.currentCatModel
		}
    }

}

// Actions
extension CatController
{
	@IBAction func categoryButtonTouched(sender: AnyObject) {
		let categoryController = UIAlertController(title: NSLocalizedString("Choose category", comment: "Category chooser title"), message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
		
		let categories: [CatCategory] = self.catViewModel?.categories ?? [ .AnyCategory ]
		for category in categories
		{
			let actionStyle: UIAlertActionStyle = {
				switch category
				{
				case .AnyCategory:
					return .Cancel
					
				case .NamedCategory(_):
					return .Default
				}
			}()
			
			categoryController.addAction(UIAlertAction(title: category.name(), style: actionStyle) {
				action in
				
				self.catViewModel?.setCategory(category)
				
				return
			})
		}
		
		self.presentViewController(categoryController, animated: true, completion: nil)
	}
	
	@IBAction func copyUrlButtonTouched(sender: AnyObject) {
		if let sourceUrl = self.catViewModel?.sourceUrlText()
		{
			UIPasteboard.generalPasteboard().string = sourceUrl
			JLToast.makeText(NSLocalizedString("Copied to pasteboard", comment: "URL copy to pasteboard"), duration: JLToastDelay.ShortDelay).show()
		}
	}
	
	@IBAction func favouriteButtonTouched(sender: AnyObject) {
		self.catViewModel?.toggleFavourite()
	}
	
	@IBAction func rateButtonTouched(sender: AnyObject) {
		let rateController = UIAlertController(title: NSLocalizedString("Rate cat!", comment: "Rating title"), message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
		
		for i in reverse(1...10)
		{
			rateController.addAction(UIAlertAction(title: "\(i)", style: .Default) {
				action in
				
				self.catViewModel?.rate(i)
			
				return
			})
		}
		
		self.presentViewController(rateController, animated: true, completion: nil)
	}
	
	@IBAction func nextButtonTouched(sender: AnyObject) {
		self.catViewModel?.fetchCat()
	}
}

// Helpers
extension CatController
{
	final func updateFields(catViewModel: CatViewModel, updateMask: Int)	// final added as a workaround, otherwise compiler will crash with a signal 11 generating code for this method
	{
		let shouldUpdateCategory: Bool = updateMask & UpdateField.UpdateCategory.rawValue != 0
		let shouldUpdateControls: Bool = updateMask & UpdateField.UpdateControls.rawValue != 0
		let shouldUpdateModel: Bool = updateMask & UpdateField.UpdateModel.rawValue != 0
		let shouldUpdateProgress: Bool = updateMask & UpdateField.UpdateProgress.rawValue != 0
		
		if shouldUpdateCategory
		{
			self.categoryButton.setTitle(catViewModel.currentCategory.name(), forState: .Normal)
		}
		if shouldUpdateControls
		{
			enableControls(catViewModel.shouldEnableControls)
			self.favouriteButton?.setImage(catViewModel.favouriteButtonImage(), forState: .Normal)
			self.rateButton?.setImage(catViewModel.rateButtonImage(), forState: .Normal)
		}
		if shouldUpdateModel
		{
			self.catImageView?.image = catViewModel.catImage()
			self.urlTextField?.text = catViewModel.sourceUrlText()
		}
		if shouldUpdateProgress
		{
			self.downloadProgress?.progress = catViewModel.currentProgress
		}
		
		return
	}
	
	func enableControls(enabled: Bool)
	{
		self.categoryButton?.enabled = enabled
		
		self.rateButton?.enabled = enabled
		self.favouriteButton?.enabled = enabled
		self.nextButton?.enabled = enabled
		self.zoomButton?.enabled = enabled
		
		self.copyButton?.enabled = enabled
	}
}
