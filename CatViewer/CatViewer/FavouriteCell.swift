//
//  FavouriteCell.swift
//  CatViewer
//
//  Created by José Servet Font on 7/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import UIKit

class FavouriteCell: UITableViewCell {

	@IBOutlet var thumbnailImageView: UIImageView!
	@IBOutlet var dateLabel: UILabel!
	
	var favourite: Favourite? {
		didSet {
			self.thumbnailImageView?.image = nil
			self.dateLabel?.text = ""
			
			if let favourite = self.favourite
			{
				if let sinceDate = favourite.date
				{
					let formatter = NSDateFormatter()
					formatter.dateStyle = .MediumStyle
					formatter.timeStyle = .MediumStyle
					
					self.dateLabel?.text = formatter.stringFromDate(sinceDate)
				}
			}
			
			if let thumbnailData = self.favourite?.cat?.thumbnail?.data
			{
				self.thumbnailImageView?.image = UIImage(data: thumbnailData)
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
