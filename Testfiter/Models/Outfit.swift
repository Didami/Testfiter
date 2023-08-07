//
//  Outfit.swift
//  Outfiter
//
//  Created by Didami on 05/08/22.
//

// MARK: - PATENTED

import UIKit

class Outfit: NSObject, Codable {
    
    @objc var name: String?
    
    var dressCode: GarmentDressCode?
    
    var garmentsUids: [GarmentType: String?] = [
        .Top: nil,
        .Bottom: nil,
        .Hoodie: nil,
        .Jacket: nil,
        .Shoes: nil,
    ]
    
    @objc var uid: String?
    
    init(name: String, dressCode: GarmentDressCode, uid: String, garments: [Garment?]) {
        self.name = name
        self.dressCode = dressCode
        self.uid = uid
        
        let existingGarments = garments.compactMap({ $0 })
        for existingGarment in existingGarments {
            if let type = existingGarment.type {
                self.garmentsUids[type] = existingGarment.uid
            }
        }
    }
    
    func garments() -> [Garment?] {
        
        var garments = [Garment?]()
        
        UserDefaultsManager.shared.fetchGarments { result in
            switch result {
            case .success(let fetched):
                
                for (_, uid) in self.garmentsUids {
                    garments.append(fetched.first(where: { $0.uid == uid }))
                }
                
            case .failure(_):
                garments.removeAll()
            }
        }
        
        return garments.sorted(by: { ($0?.type?.order ?? 5) < ($1?.type?.order ?? 5) })
    }
    
    func dominantColors() -> [Color] {
        
        var colors = [Color?]()
        
        let extistingGarments = garments().compactMap({ $0 })
        for garment in extistingGarments {
            colors.append(garment.mainColor)
        }
        
        var dictionary = [Color: Int]()

        for value in colors.compactMap({ $0 }) {
            let index = dictionary[value] ?? 0
            dictionary[value] = index + 1
        }
        
        let result = dictionary.sorted(by: { $0.1 > $1.1 }).map({ $0.0 })
        
        return result
    }
    
    func createNameWithColors() -> String {
        var title = ""
        
        dominantColors().prefix(3).forEach { color in
            title.append("\(color.display.localized().capitalized)+")
        }
        
        if !title.isEmpty() {
            title.removeLast()
        }
        
        return title
    }
    
    func containsMandatory() -> Bool {
        return garmentsUids.filter({ $0.0 == .Top || $0.0 == .Bottom || $0.0 == .Shoes }).allSatisfy({ $0.1 != nil })
    }
}

extension Outfit {
    public func hasImage() -> Bool {
        guard let uid = self.uid else { return false }
        return LocalImageManager.shared.getSavedImage(uid: uid) != nil
    }
}

enum OutfitRenderOptions: String, CaseIterable {
    case Grid
    case Free
    case Caroussel
    // TODO: Photo render
//    case Photo
}

func outfitRenderForDisplay(_ display: String) -> OutfitRenderOptions {
    switch display.localized() {
    case "Grid".localized(): return .Grid
    case "Free".localized(): return .Free
    case "Caroussel".localized(): return .Caroussel
    // TODO: Photo render
//    case "Photo".localized(): return .Photo
    default: return .Grid
    }
}

enum OutfitAccuracy: String, CaseIterable {
    case Broader
    case Balanced
    case Accurate
}

func outfitAccuracyForDisplay(_ display: String) -> OutfitAccuracy {
    switch display.localized() {
    case "Broader".localized(): return .Broader
    case "Balanced".localized(): return .Balanced
    case "Accurate".localized(): return .Accurate
    default: return .Broader
    }
}


class OutfitDate: NSObject, Codable {
    
    var day: Int?
    var month: Int?
    var year: Int?
    
    init(day: Int, month: Int, year: Int) {
        self.day = day
        self.month = month
        self.year = year
    }
    
    init(date: Date?) {
        guard let date = date else { return }
        self.day = CalendarService.shared.dayOf(date: date)
        self.month = CalendarService.shared.monthOf(date: date)
        self.year = CalendarService.shared.yearOf(date: date)
    }
    
    func string() -> String {
        
        guard let day = self.day, let month = self.month, let year = self.year else {
            return ""
        }
        
        return "\(day)/\(month)/\(year)"
    }
}

func outfitDateFromString(_ string: String) -> OutfitDate {
    let components = string.components(separatedBy: "/")
    return OutfitDate(day: Int(components[0]) ?? 1, month: Int(components[1]) ?? 1, year: Int(components[2]) ?? 1970)
}

/*
   ==.---.
     |^   |  __
      /====\/  \
      |====|\../
      \====/
        \/
*/
