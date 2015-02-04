//
//  BinaryData.swift
//  CatViewer
//
//  Created by Dylvian on 4/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation
import CoreData

class BinaryData: NSManagedObject {

    @NSManaged var url: String
    @NSManaged var data: NSData
    @NSManaged var catPicture: NSManagedObject
    @NSManaged var catThumbnail: NSManagedObject

}
