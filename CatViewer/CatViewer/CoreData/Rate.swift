//
//  Rate.swift
//  CatViewer
//
//  Created by Dylvian on 4/2/15.
//  Copyright (c) 2015 ByBDesigns. All rights reserved.
//

import Foundation
import CoreData

class Rate: NSManagedObject {

    @NSManaged var rate: NSNumber
    @NSManaged var cat: NSManagedObject

}
