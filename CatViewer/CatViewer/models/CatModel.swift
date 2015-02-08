//
//  CatModel.swift
//  CatViewer
//
//  Created by Boolky Bear on 6/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import UIKit

//import Alamofire

typealias ProgressHandler = (Float) -> Void
typealias FinishHandler = () -> Void

class CatModel {
	var url: String? = nil
	var identifier: String? = nil
	var sourceUrl: String? = nil
	
	var imageData: NSData? = nil
	var thumbnailImageData: NSData? = nil
	
	private var handleProgress: ProgressHandler? = nil
	private var handleFinish: FinishHandler? = nil
	
	func onProgress(handler: ProgressHandler) -> Self
	{
		self.handleProgress = handler
		
		return self
	}
	
	func onFinish(handler: FinishHandler) -> Self
	{
		self.handleFinish = handler
		
		return self
	}
	
	func fetchImageData()
	{
		if let catImageUrl = self.url
		{
//			dispatch_async(dispatch_get_main_queue()) {
//				UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//				
//				return
//			}
//			
//			Alamofire.request(Alamofire.Method.GET, catImageUrl)
//				.validate()
//				.progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
//					dispatch_async(dispatch_get_main_queue()) {
//						self.handleProgress?(Float(totalBytesExpectedToRead) == 0.0 ? 0.0 : Float(totalBytesRead)/Float(totalBytesExpectedToRead))
//						
//						return
//					}
//					
//					return
//				}
//				.response { (request, _, imageData, error) in
//					if let imageData = imageData as? NSData
//					{
//						self.imageData = imageData
//					}
//					
//					self.handleFinish?()
//			}
		}
	}
}
