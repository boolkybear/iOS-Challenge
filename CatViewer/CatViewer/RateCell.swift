//
//  RateCell.swift
//  CatViewer
//
//  Created by Boolky Bear on 8/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import UIKit

class RateCell: UITableViewCell {
	
	var rate: Rate? {
		didSet {
			// TODO: setup UI
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
