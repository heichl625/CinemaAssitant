//
//  Cinema.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 30/11/2019.
//  Copyright © 2019 Cheuk Hei Lo. All rights reserved.
//

import Foundation
import RealmSwift

class Cinema: Object {
    
    @objc dynamic var cinemaName: String? = nil
    @objc dynamic var address: String? = nil
    @objc dynamic var district: String? = nil
    @objc dynamic var imageURL: String? = nil
    var noOfHouses = RealmOptional<Int>()
    @objc dynamic var tel: String? = nil
    
}

