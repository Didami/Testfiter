//
//  Garment.swift
//  Outfiter
//
//  Created by Didami on 01/08/22.
//

// MARK: - PATENTED

import UIKit

class Garment: NSObject, Codable {
    
    @objc var name: String?
    
    var type: GarmentType?
    var dressCode: [GarmentDressCode]?
    var weather: [GarmentWeather]?
    
    var hex_bri: [String: Float]?
    var mainColor: Color?
    var averageBrightness: Float?
    var pattern: GarmentPattern?
    
    var wearCount: Int?
    
    var disabled: Bool?
    var overlayMatch: Bool?
    
    @objc var uid: String?
    
    override init() {
        super.init()
    }
    
    init(type: GarmentType, dressCode: [GarmentDressCode], weather: [GarmentWeather], name: String, uid: String, colors: [String], pattern: GarmentPattern, overlayMatch: Bool) {
        
        self.type = type
        self.dressCode = dressCode
        self.weather = weather
        self.name = name
        self.pattern = pattern
        
        self.uid = uid
        
        self.averageBrightness = Float(colors.map({ UIColor(hex: $0)! }).map({ $0.hsb?.brightness ?? 1.0 }).map({ Double($0) }).compactMap({ $0 }).average())
        self.wearCount = 0
        self.overlayMatch = overlayMatch
        
        self.hex_bri = [:]
        for (i, hex) in colors.enumerated() {
            let color = UIColor(hex: hex)
            self.hex_bri?["\(i + 1)-\(hex)"] = Float(color?.hsb?.brightness ?? 1.0)
        }
        
        self.mainColor = UIColor(hex: colors.first!)!.color()
    }
    
    public func insertHexBri(color: UIColor, at index: Int) {
        if let bri = color.hsb?.brightness {
            self.removeHexBriAt(index)
            self.hex_bri?["\(index + 1)-\(color.hexString())"] = Float(bri)
        }
    }
    
    public func removeHexBriAt(_ index: Int) {
        if !(hexColors().count - 1 < index) {
            let hex = hexColors()[index]
            self.hex_bri?["\(index + 1)-\(hex)"] = nil
        }
    }
    
    public func hexColors() -> [String] {
        guard let hex_bri = hex_bri else { return [] }
        return hex_bri.keys.sorted().map({ $0.components(separatedBy: "-").last ?? "#FFFFFFff" })
    }
    
    public func enumColors() -> [Color] {
        return hexColorsToColors(self.hexColors())
    }
}

// Garment Type
enum GarmentType: String, CaseIterable, Codable {
    case Top
    case Bottom
    case Hoodie
    case Jacket
    case Shoes
    
    var order: Int {
        switch self {
        case .Top: return 1
        case .Bottom: return 2
        case .Hoodie: return 3
        case .Jacket: return 4
        case .Shoes: return 5
        }
    }
    
    var zOrder: Int {
        switch self {
        case .Top: return 4
        case .Bottom: return 5
        case .Hoodie: return 3
        case .Jacket: return 2
        case .Shoes: return 1
        }
    }
    
    var display: String {
        switch self {
        case .Top: return "Top"
        case .Bottom: return "Bottom"
        case .Hoodie: return "Hoodie & Sweatshirt"
        case .Jacket: return "Coat & Jacket"
        case .Shoes: return "Shoes"
        }
    }
}

extension GarmentType: Comparable {
    
    static func < (lhs: GarmentType, rhs: GarmentType) -> Bool {
        lhs.order < rhs.order
    }
    
    public func patternsForType() -> [GarmentPattern] {
        var patterns: [GarmentPattern] = []
        
        switch self {
        case .Top:
            patterns.append(contentsOf: [.Solid, .HStripes, .VStripes])
        case .Bottom:
            patterns.append(contentsOf: [.Solid, .Denim])
        case .Hoodie:
            patterns.append(contentsOf: [.Solid])
        case .Jacket:
            patterns.append(contentsOf: [.Solid, .Denim])
        case .Shoes:
            patterns.append(contentsOf: [.Solid])
        }
        
        return patterns
    }
}

extension Garment {
    public func hasImage() -> Bool {
        guard let uid = self.uid else { return false }
        return LocalImageManager.shared.getSavedImage(uid: uid) != nil
    }
}

func garmentTypeForDisplay(_ display: String) -> GarmentType {
    switch display.localized() {
    case "Top".localized(): return .Top
    case "Bottom".localized(): return .Bottom
    case "Hoodie & Sweatshirt".localized(): return .Hoodie
    case "Coat & Jacket".localized(): return .Jacket
    case "Shoes".localized(): return .Shoes
        
    default: return .Top
    }
}

func garmentTypeForIndex(_ index: Int) -> GarmentType {
    switch index {
    case 1: return .Top
    case 2: return .Bottom
    case 3: return .Hoodie
    case 4: return .Jacket
    case 5: return .Shoes
        
    default: return .Top
    }
}

func garmentTypesInArray(_ array: [Garment]) -> [GarmentType] {
    
    var types = [GarmentType]()
    
    for item in array {
        
        if let type = item.type {
            
            if !types.contains(type) {
                types.append(type)
            }
        }
    }
    
    return types
}

func indexForGarmentType(_ type: GarmentType, in garments: [Garment?], shouldConsiderNilValues: Bool = false, shouldSubstract: Bool = false) -> Int {
    
    let existingGarments = shouldConsiderNilValues ? garments : garments.compactMap({ $0 })
    // single garment, return first index
    if existingGarments.count == 0 {
        return 0
    }
    
    // all garments, return order index
    if existingGarments.count == GarmentType.allCases.count {
        return type.order - 1
    }
    
    // special cases where Top always should be first and Shoes always last
    if type == .Top {
        return 0
    } else if type == .Shoes {
        return existingGarments.count - (shouldSubstract ? 1 : 0)
    }
    
    if type == .Jacket && !existingGarments.contains(where: { $0?.type == .Hoodie }) {
        return 2
    }
    
    // variable garments, return the next index after existing garments prefix
    if let typeFirstIndex = existingGarments.firstIndex(where: { $0?.type == type }) {
        let index = existingGarments.prefix(typeFirstIndex).count
        return index
    } else {
        return type.order - 1
    }
}

func gridOrderToCarousselOrder(_ index: Int) -> Int {
    switch index {
    case 0:
        // Top
        return 0
    case 1:
        // Bottom
        return 3
    case 2:
        // Hoodie
        return 1
    case 3:
        // Jacket
        return 2
    case 4:
        // Shoes
        return 4
    default:
        return 0
    }
}

func carousselOrderToGridOrder(_ index: Int) -> Int {
    switch index {
    case 0:
        // Top
        return 0
    case 1:
        // Hoodie
        return 2
    case 2:
        // Jacket
        return 3
    case 3:
        // Bottom
        return 1
    case 4:
        // Shoes
        return 4
    default:
        return 0
    }
}

// Garment DressCode
enum GarmentDressCode: String, CaseIterable, Codable {
    case Casual
    case SemiFormal = "Semi-Formal"
    case Formal
    case Informal
    case Mixed
    
    var order: Int {
        switch self {
        case .Casual: return 1
        case .SemiFormal: return 2
        case .Formal: return 3
        case .Informal: return 4
        case .Mixed: return 5
        }
    }
}

func garmentDressCodeForDisplay(_ display: String) -> GarmentDressCode {
    switch display {
    case "Casual".localized(): return .Casual
    case "Semi-Formal".localized(): return .SemiFormal
    case "Formal".localized(): return .Formal
    case "Informal".localized(): return .Informal
    case "Mixed".localized(): return .Mixed
        
    default: return .Casual
    }
}

extension GarmentDressCode: Comparable {
    
    static func < (lhs: GarmentDressCode, rhs: GarmentDressCode) -> Bool {
        lhs.order < rhs.order
    }
}

// Garment Weather
enum GarmentWeather: String, CaseIterable, Codable {
    
    case Neutral
    case Lightweight
    case Midpoint
    case Warm
    
    var order: Int {
        switch self {
        case .Neutral: return 1
        case .Lightweight: return 2
        case .Midpoint: return 3
        case .Warm: return 4
        }
    }
}

func garmentWeatherForDisplay(_ display: String) -> GarmentWeather {
    switch display {
    case "Neutral".localized(): return .Neutral
    case "Lightweight".localized(): return .Lightweight
    case "Midpoint".localized(): return .Midpoint
    case "Warm".localized(): return .Warm
    
    default: return .Neutral
    }
}

// Garment Pattern
enum GarmentPattern: String, CaseIterable, Codable {
    case Solid
    case Denim
    case HStripes = "horizontal-stripes"
    case VStripes = "vertical-stripes"
    case Auto
}

/*
   ==.---.
     |^   |  __
      /====\/  \
      |====|\../
      \====/
        \/
*/
