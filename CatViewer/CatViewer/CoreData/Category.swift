//
//  Category.swift
//  CatViewer
//
//  Created by Boolky Bear on 4/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation
import CoreData

class Category: NSManagedObject {

    @NSManaged var identifier: String
    @NSManaged var name: String

}
