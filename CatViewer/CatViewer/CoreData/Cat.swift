//
//  Cat.swift
//  CatViewer
//
//  Created by Dylvian on 4/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation
import CoreData

class Cat: NSManagedObject {

    @NSManaged var identifier: String
    @NSManaged var url: String
    @NSManaged var sourceUrl: String
    @NSManaged var rate: Rate
    @NSManaged var favourite: Favourite
    @NSManaged var picture: BinaryData
    @NSManaged var thumbnail: BinaryData

}
