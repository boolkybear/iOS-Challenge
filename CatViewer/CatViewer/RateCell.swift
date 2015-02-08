//
//  RateCell.swift
//  CatViewer
//
//  Created by Boolky Bear on 8/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import UIKit

class RateCell: UITableViewCell {
	
	@IBOutlet var catImageView: UIImageView!
	@IBOutlet var rateLabel: UILabel!
	@IBOutlet var rateProgress: UIProgressView!
	
	var rate: Rate? {
		didSet {
			self.catImageView?.image = nil
			self.rateLabel?.text = ""
			self.rateProgress?.progress = 0.0
			
			if let rate = self.rate
			{
				if let rateNumber = rate.rate?.intValue
				{
					self.rateLabel?.text = "\(rateNumber)"
					self.rateProgress?.progress = Float(rateNumber) / 10.0
				}
			}
			
			if let thumbnailData = self.rate?.cat?.thumbnail?.data
			{
				self.catImageView?.image = UIImage(data: thumbnailData)
			}
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
