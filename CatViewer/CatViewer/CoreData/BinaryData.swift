//
//  BinaryData.swift
//  CatViewer
//
//  Created by Boolky Bear on 4/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation
import CoreData

class BinaryData: NSManagedObject {

    @NSManaged var url: String?
    @NSManaged var data: NSData?
    @NSManaged var catPicture: Cat?
    @NSManaged var catThumbnail: Cat?

}
