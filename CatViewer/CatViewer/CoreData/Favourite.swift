//
//  Favourite.swift
//  CatViewer
//
//  Created by Boolky Bear on 4/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation
import CoreData

class Favourite: NSManagedObject {

    @NSManaged var date: NSDate?
    @NSManaged var cat: Cat?

}
