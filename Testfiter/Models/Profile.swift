//
//  Profile.swift
//  Testfiter
//
//  Created by Didami on 09/08/23.
//

// MARK: - TESTING

import UIKit

class Profile: NSObject, Codable {
    
    @objc var name: String?
    @objc var uid: String?
    
    var garments: [Garment]?
    var outfits: [Outfit]?
    
    var ootdUid: String?
    
    init(name: String, garments: [Garment], outfits: [Outfit], uid: String) {
        self.name = name
        self.garments = garments
        self.outfits = outfits
        self.uid = uid
    }
}
