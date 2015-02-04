//
//  CatController.swift
//  CatViewer
//
//  Created by Dylvian on 4/2/15.
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

        // Do any additional setup after loading the view.
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
	}
}

// Helpers
extension CatController
{
	func fetchCat()
	{
		self.downloadProgress.progress = 0.0
		self.downloadProgress.hidden = false
		
		Alamofire.request(Alamofire.Method.GET, "http://thecatapi.com/api/images/get", parameters: [ "format" : "xml" ])
			.validate()
			.progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
				self.downloadProgress?.progress = Float(totalBytesExpectedToRead) == 0.0 ? 0.0 : Float(totalBytesRead)/Float(totalBytesExpectedToRead)
				
				return
			}
			.responseString { (request, _, xmlData, error) in
				if let error = error
				{
					println("Error downloading request \(request): \(error.localizedDescription)")
				}
				else
				{
					println("Downloaded XML: \(xmlData)")
				}
			}
		
	}
}
