//
//  ViewerController.swift
//  CatViewer
//
//  Created by Boolky Bear on 8/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import UIKit

class ViewerController: UIViewController {

	@IBOutlet var zoomScrollView: UIScrollView!
	@IBOutlet var catImageView: UIImageView!
	
	var cat: Cat? {
		didSet {
			updateCatImageViewWithData(self.cat?.picture?.data)
		}
	}
	
	var catModel: CatModel? {
		didSet {
			updateCatImageViewWithData(self.catModel?.imageData)
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		// TODO: set image constraints

        // Do any additional setup after loading the view.
		updateCatImageViewWithData(self.cat?.picture?.data ?? self.catModel?.imageData)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(true)
		
		self.navigationController?.hidesBarsOnTap = true
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.navigationController?.hidesBarsOnTap = false
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

// Helpers
extension ViewerController
{
	func updateCatImageViewWithData(data: NSData?)
	{
		self.zoomScrollView?.zoomScale = 1.0	// reset scale
		self.catImageView?.image = nil
		
		if let data = data
		{
			self.catImageView?.image = UIImage(data: data)
		}
	}
}

extension ViewerController: UIScrollViewDelegate
{
	func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
		return self.catImageView
	}
}
