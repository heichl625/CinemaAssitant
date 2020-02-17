//
//  SessionFeed.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 16/2/2020.
//  Copyright © 2020 Cheuk Hei Lo. All rights reserved.
//

import Foundation
import RealmSwift

class SessionFeed: Object {
    
    @objc dynamic var movieID: String? = nil
    @objc dynamic var sessionID: String? = nil
    @objc dynamic var movieName: String? = nil
    @objc dynamic var movieTime: String? = nil
    @objc dynamic var movieDate: String? = nil
    @objc dynamic var movieLang: String? = nil
    @objc dynamic var movieFormat: String? = nil
    @objc dynamic var movieOnShowHouse: String? = nil
    @objc dynamic var movieOnShowDay: String? = nil
    @objc dynamic var movieAdultPrice: Int = 0
    @objc dynamic var movieStudentPrice: Int = 0
    @objc dynamic var movieChildPrice: Int = 0
    @objc dynamic var movieSeniorPrice: Int = 0
    
    
}
