//
//  MovieFeed.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 30/12/2019.
//  Copyright © 2019 Cheuk Hei Lo. All rights reserved.
//

import Foundation
import RealmSwift

class MovieFeed: Object {
    
    @objc dynamic var id: String? = nil
    @objc dynamic var title: String? = nil
    @objc dynamic var poster_path: String? = nil
    @objc dynamic var original_title: String? = nil
    @objc dynamic var overview: String? = nil
    @objc dynamic var release_date: String? = nil
    
}
