//
//  Cinema+CoreDataProperties.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 15/4/2020.
//  Copyright © 2020 Cheuk Hei Lo. All rights reserved.
//
//

import Foundation
import CoreData


extension Cinema {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cinema> {
        return NSFetchRequest<Cinema>(entityName: "Cinema")
    }

    @NSManaged public var cinemaName: String?
    @NSManaged public var cinemaGroup: String?
    @NSManaged public var cinemaID: Int16
    @NSManaged public var address: String?
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var tel: String?
    @NSManaged public var thumbnails: Data?
    @NSManaged public var fullImage: Data?
    @NSManaged public var district: String?

}
