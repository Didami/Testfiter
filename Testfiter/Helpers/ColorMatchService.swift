//
//  ColorMatchService.swift
//  Outfiter
//
//  Created by Didami on 14/08/22.
//

// MARK: - PATENTED

import UIKit

var shouldConsiderCyanBlueNeutral = false

enum Color: String, CaseIterable, Comparable, Codable {
    case red, orange, yellow, yellowGreen, green, greenCyan, cyan, cyanBlue, blue, purple, magenta, magentaRed, neutral
    case militar, brown, beige
    
    var order: Int {
        switch self {
        case .neutral: return 1
        case .red: return 2
        case .orange: return 3
        case .yellow: return 4
        case .yellowGreen: return 5
        case .green: return 6
        case .greenCyan: return 7
        case .cyan: return 8
        case .cyanBlue: return 9
        case .blue: return 10
        case .purple: return 11
        case .magenta: return 12
        case .magentaRed: return 13
        case .militar: return 14
        case .brown: return 15
        case .beige: return 16
        }
    }
    
    static func < (lhs: Color, rhs: Color) -> Bool {
        lhs.order < rhs.order
    }
    
    var display: String {
        switch self {
        case .neutral: return rawValue
        case .red: return rawValue
        case .orange: return rawValue
        case .yellow: return rawValue
        case .yellowGreen: return "yellow green"
        case .green: return rawValue
        case .greenCyan: return "green cyan"
        case .cyan: return rawValue
        case .cyanBlue: return "cyan blue"
        case .blue: return rawValue
        case .purple: return "purple"
        case .magenta: return rawValue
        case .magentaRed: return "magenta red"
        case .militar: return rawValue
        case .brown: return rawValue
        case .beige: return rawValue
        }
    }
    
    static func random() -> Color {
        return Color.allCases.randomElement() ?? .neutral
    }
    
    var uicolor: UIColor {
        var hex = "#FFFFFF"
        switch self {
        case .neutral: hex = "#FFFFFF"
        case .red: hex = "#FF0000"
        case .orange: hex = "#FF8000"
        case .yellow: hex = "#FFFF00"
        case .yellowGreen: hex = "#80FF00"
        case .green: hex = "#00FF00"
        case .greenCyan: hex = "#00FF80"
        case .cyan: hex = "#00FFFF"
        case .cyanBlue: hex = "#0080FF"
        case .blue: hex = "#0000FF"
        case .purple: hex = "#8000FF"
        case .magenta: hex = "#FF00FF"
        case .magentaRed: hex = "#FF0080"
        case .militar: hex = "#7F7F40"
        case .brown: hex = "#663D14"
        case .beige: hex = "#CFB997"
        }
        return UIColor(hex: "\(hex)ff") ?? .white
    }
}

enum ColorType: String {
    case warm
    case cool
    case neutral
}

extension Color {
    
    static var warmColors: [Color] {
        return [.red, .orange, .yellow, .yellowGreen, .magentaRed, .brown]
    }
    
    static var coolColors: [Color] {
        var base: [Color] = [.green, .greenCyan, .cyan, .blue, .purple, .magenta]
        if !shouldConsiderCyanBlueNeutral { base.append(.cyanBlue) }
        return base
    }
    
    static var neutralColors: [Color] {
        var base: [Color] = [.neutral, .beige]
        if shouldConsiderCyanBlueNeutral { base.append(.cyanBlue) }
        return base
    }
    
    static let balancedMatchingColors: [Color: [Color]] = [
        // red
        .red: [.neutral, .beige, .red, .cyanBlue, .blue],
        // orange
        .orange: [.neutral, .beige, .orange, .brown],
        // yellow
        .yellow: [.neutral, .beige, .yellow, .yellowGreen, .green],
        // yellowGreen
        .yellowGreen: [.neutral, .beige, .yellowGreen, .yellow],
        // green
        .green: [.neutral, .beige, .greenCyan, .yellow, .yellowGreen, .militar],
        // greenCyan
        .greenCyan: [.neutral, .beige, .greenCyan, .green, .cyan],
        // cyan
        .cyan: [.neutral, .beige, .cyan, .cyanBlue, .greenCyan],
        // cyanBlue
        .cyanBlue: [.neutral, .beige, .cyanBlue, .blue, .brown],
        // blue
        .blue: [.neutral, .beige, .blue, .purple, .cyanBlue, .brown],
        // purple
        .purple: [.neutral, .beige, .purple, .blue, .cyanBlue, .magenta, .brown],
        // magenta
        .magenta: [.neutral, .beige, .magenta, .magentaRed, .purple],
        // magentaRed
        .magentaRed: [.neutral, .beige, .magentaRed, .red, .magenta],
        
        // militar
        .militar: [.neutral, .beige, .green],
        // brown
        .brown: [.neutral, .beige, .cyanBlue, .blue, .purple],
        // beige
        .beige: Color.allCases,
        
        // neutral
        .neutral: Color.allCases,
    ]
    
    static let gptMatchingColors: [Color: [Color]] = [
        // red
        .red: Color.neutralColors + Color.warmColors,
        // orange
        .orange: Color.neutralColors + Color.warmColors,
        // yellow
        .yellow: Color.neutralColors + Color.warmColors,
        // yellowGreen
        .yellowGreen: Color.neutralColors + Color.warmColors,
        // green
        .green: Color.neutralColors + Color.coolColors + [.militar],
        // greenCyan
        .greenCyan: Color.neutralColors + Color.coolColors,
        // cyan
        .cyan: Color.neutralColors + Color.coolColors,
        // cyanBlue
        .cyanBlue: Color.neutralColors + Color.coolColors,
        // blue
        .blue: Color.neutralColors + Color.coolColors,
        // purple
        .purple: Color.neutralColors + Color.coolColors,
        // magenta
        .magenta: Color.neutralColors + Color.coolColors,
        // magentaRed
        .magentaRed: Color.neutralColors + Color.warmColors,
        
        // militar
        .militar: [.militar] + Color.neutralColors + [.green],
        // brown
        .brown: Color.allCases,
        // beige
        .beige: Color.allCases,
        
        // neutral
        .neutral: Color.allCases,
    ]
    
    public func matchesWithColor(_ color: Color) -> Bool {
        return Color.gptMatchingColors[self]?.contains(color) ?? false
    }
}

struct OutfitCriteria {
    var dressCode: [GarmentDressCode] = [.Casual]
    var accuracy: OutfitAccuracy = .Balanced
    var weather: GarmentWeather = .Neutral
    var previousGarments: [Garment] = []
    var lockedTypes: [GarmentType] = []
}

extension [UIColor] {
    
    func matchingPercentage() -> CGFloat {
        
        let garmentsColors = UserDefaultsManager.shared.fetchColors()
        
        let hexBri = self.map({ [$0.hexString(): Float($0.hsb?.brightness ?? 1.0)] })
        
        var percentage: CGFloat = 0
        hexBri.forEach { dict in
            for (hex, _) in dict {
                guard let hex = hex.components(separatedBy: "-").last else { return }
                if UIColor(hex: hex)?.color() == .neutral {
                    percentage += CGFloat(1.0 / Float(self.count))
                } else {
                    for garmentColors in garmentsColors {
                        if dict.matchesWith(garmentColors) {
                            percentage += CGFloat(1.0 / Float(garmentsColors.count) / Float(self.count))
                        }
                    }
                }
            }
        }
        
        return percentage
    }
}

extension [String: Float] {
    
    func matchesWith(_ dict: [String: Float]) -> Bool {
        var matches = [Bool]()
        for (k1, v1) in self {
            if let hex1 = k1.components(separatedBy: "-").last, let color1 = UIColor(hex: hex1)?.color() {
                let bri1 = Double(v1)
                
                for (k2, v2) in dict {
                    if let hex2 = k2.components(separatedBy: "-").last, let color2 = UIColor(hex: hex2)?.color() {
                        let bri2 = Double(v2)
                        
                        if color1 == color2 {
                            matches.append(true)
                        }
                        
                        if color1 == .militar || color2 == .militar {
                            matches.append(Color.militar.matchesWithColor(color1) && Color.militar.matchesWithColor(color2))
                        }
                        
                        if (Color.warmColors.contains(color1) && Color.coolColors.contains(color2)) || (Color.coolColors.contains(color1) && Color.warmColors.contains(color2)) {
                            matches.append(bri1 > 50 || bri2 > 50)
                        } else {
                            matches.append(true)
                        }
                    }
                }
            }
        }
        
        return !matches.isEmpty && !matches.contains(false)
    }
}

func hexColorsToColors(_ hexColors: [String]) -> [Color] {
    
    var colors = [Color]()
    
    for hex in hexColors {
        
        if let color = UIColor(hex: hex)?.color() {
            colors.append(color)
        }
    }
    
    return colors
}

extension Garment {
    
    public func matchingPercentageWith(_ garment: Garment?) -> Float {
        
        let baseGarment = self
        var percentage: Float = 0
        
        guard let garment = garment, let garmentDressCode = garment.dressCode, let baseDressCode = baseGarment.dressCode, let garmentWeather = garment.weather, let baseGarmentWeather = garment.weather, let garmentHexBri = garment.hex_bri, let baseGarmentHexBri = baseGarment.hex_bri else { return percentage }
        
        shouldConsiderCyanBlueNeutral = (baseGarment.type == .Bottom && baseGarment.mainColor == .cyanBlue) || (garment.type == .Bottom && garment.mainColor == .cyanBlue)
        
        if garmentDressCode.contains(.Mixed) || baseDressCode.contains(.Mixed) {
            percentage += 0.05
        } else {
            let matches = garmentDressCode.filter({ baseDressCode.contains($0) })
            percentage += Float(matches.count) * 0.15
        }
        
        if garmentWeather.contains(.Neutral) || baseGarmentWeather.contains(.Neutral) {
            percentage += 0.05
        } else {
            let matches = garmentWeather.filter({ baseGarmentWeather.contains($0) })
            percentage += Float(matches.count) * 0.15
        }
        
        if baseGarmentHexBri.matchesWith(garmentHexBri) {
            percentage += 0.5
        }
        
        return percentage
    }
}

func matchingGarmentsFrom(_ garments: [Garment], colors: [[String: Float]], criteria: OutfitCriteria) -> [Garment] {
    
    // Get all type garments
    var matchingGarments = garments
    
    // Filter by dress code
    if !criteria.dressCode.contains(.Mixed) {
        matchingGarments.removeAll()
        for dressCode in criteria.dressCode {
            let newMatchingGarments = garments.filter({ $0.dressCode?.contains(dressCode) ?? false || $0.dressCode?.contains(.Mixed) ?? false })
            let set = Set(newMatchingGarments)
            matchingGarments = Array(set.union(matchingGarments))
        }
    }
    
    if criteria.weather == .Warm { matchingGarments.removeAll(where: { ($0.type == .Hoodie || $0.type == .Jacket) && $0.overlayMatch != true && $0.weather?.contains(.Warm) != true }) }
    
    // Loop through each garment
    for garment in matchingGarments {
        
        // Loop through each hex color of garment and convert to Color, limit to prefix
        if let garmentType = garment.type, let garmentDict = garment.hex_bri, let garmentWeather = garment.weather {
            // Loop through each of base Colors
            for dict in colors {
                // Remove looped garment if Color does not match with base Color (or viceversa)
                if !garmentDict.matchesWith(dict) || !dict.matchesWith(garmentDict) {
                    if !criteria.lockedTypes.contains(garmentType) { matchingGarments.removeAll(where: { $0 == garment }) }
                } else {
                    // If it does match
                    // Id garment weather is not adequated, remove; add garment twice if it is adequated.
                    if !garmentWeather.contains(.Neutral) && !garmentWeather.contains(criteria.weather) {
                        if !criteria.lockedTypes.contains(garmentType) { matchingGarments.removeAll(where: { $0 == garment }) }
                    } else if garmentWeather.contains(criteria.weather) {
                        matchingGarments.append(garment)
                    }
                }
            }
        }
    }
    
    return matchingGarments.adjustRandomProbabilities()
}

func createOutfitWith(_ garments: [Garment], criteria: OutfitCriteria, repeatCount: Int = 0) -> [Garment?] {
    
    var outfitGarments = [Garment?]()
    
    // Base on
    var topGarments = garments.filter({ $0.type == .Top })
    
    // Dress code
    if !criteria.dressCode.contains(.Mixed) {
        let allTopGarments = topGarments
        topGarments.removeAll()
        
        for dressCode in criteria.dressCode {
            let newMatchingGarments = allTopGarments.filter({ $0.dressCode?.contains(dressCode) ?? false || $0.dressCode?.contains(.Mixed) ?? false })
            let set = Set(newMatchingGarments)
            topGarments = Array(set.union(topGarments))
        }
    }
    
    // Get base properties
    guard let baseGarment = !criteria.lockedTypes.isEmpty ? criteria.previousGarments.first(where: { $0.type == criteria.lockedTypes.first }) : (!criteria.previousGarments.isEmpty ? criteria.previousGarments.first : topGarments.randomElement()) else {
        return []
    }
    
    guard let colorDict = baseGarment.hex_bri else {
        return []
    }
    
    var colors: [[String: Float]] = [colorDict]
    
    // Get rest of garments based on properties
    let top = matchingGarmentsFrom(garments, colors: colors, criteria: criteria).filter({ $0.type == .Top }).randomElement()
    colors.append(top?.hex_bri ?? [:])
    
    let bottom = matchingGarmentsFrom(garments, colors: colors, criteria: criteria).filter({ $0.type == .Bottom }).randomElement()
    colors.append(bottom?.hex_bri ?? [:])
    
    let shoes = matchingGarmentsFrom(garments, colors: colors, criteria: criteria).filter({ $0.type == .Shoes }).randomElement()
    colors.append(shoes?.hex_bri ?? [:])
    
    // Get optional garments
    let hoodie = matchingGarmentsFrom(garments, colors: colors, criteria: criteria).filter({ $0.type == .Hoodie }).randomElement()
    colors.append(hoodie?.hex_bri ?? [:])
    
    let jacket = matchingGarmentsFrom(garments, colors: colors, criteria: criteria).filter({ $0.type == .Jacket }).randomElement()
    colors.append(jacket?.hex_bri ?? [:])
    
    // Create and sort array based on outfit order
    var matchedGarments = [top, bottom, hoodie, jacket, shoes]
    
    // Overlay probability
    var overlayProbability: Double = 1/4
    switch criteria.weather {
    case .Neutral:
        overlayProbability = 1/4
    case .Midpoint:
        overlayProbability = 1/3
    case .Lightweight:
        overlayProbability = 0
    case .Warm:
        overlayProbability = 1
    }
    
    let randomOverlay = Int.random(in: 0...1)
    
    let noOverlayGarments = matchedGarments.compactMap({ $0 }).filter({ $0.type == .Hoodie || $0.type == .Jacket }).filter({ $0.overlayMatch != true })
    let lockedGarmentsContainNoOverlay = ((criteria.lockedTypes.contains(.Hoodie) || criteria.lockedTypes.contains(.Jacket)) && criteria.previousGarments.filter({ $0.type == .Hoodie || $0.type == .Jacket }).contains(where: { $0.overlayMatch != true }))
    if !noOverlayGarments.isEmpty || lockedGarmentsContainNoOverlay {
        if (criteria.lockedTypes.contains(.Hoodie) || criteria.lockedTypes.contains(.Jacket)) && !(criteria.lockedTypes.contains(.Hoodie) && criteria.lockedTypes.contains(.Jacket)) {
            // Single overlay lock type, base on that
            if let overlayLockedType = criteria.lockedTypes.first(where: { $0 == .Hoodie || $0 == .Jacket }) {
                let inverted: GarmentType = overlayLockedType == .Jacket ? .Hoodie : .Jacket
                matchedGarments.removeAll(where: { $0?.type == inverted })
            }
        } else {
            // Random
            var type: GarmentType = randomOverlay == 0 ? .Jacket : .Hoodie
            
            // If base type is jacket, invert order
            if baseGarment.type == .Jacket {
                type = .Hoodie
            }
            
            // If base type is hoodie, invert order
            if baseGarment.type == .Hoodie {
                type = .Jacket
            }
            
            matchedGarments.removeAll(where: { $0?.type == type })
        }
    } else {
        // Remove optional garments depending on random double
        if Double.random(in: 0.01...1) > overlayProbability {
            
            var type: GarmentType = randomOverlay == 0 ? .Hoodie : .Jacket
            
            // If base type is jacket, invert order
            if baseGarment.type == .Jacket {
                type = .Jacket
            }
            
            if !criteria.lockedTypes.contains(type) {
                matchedGarments.removeAll(where: { $0?.type == type })
            }
        } else {
            if criteria.weather == .Neutral || criteria.weather == .Midpoint { overlayProbability = overlayProbability/2 }
        }
        
        if Double.random(in: 0.01...1) > overlayProbability {
            
            var type: GarmentType = randomOverlay == 0 ? .Jacket : .Hoodie
            
            // If base type is jacket, invert order
            if baseGarment.type == .Jacket {
                type = .Hoodie
            }
            
            if !criteria.lockedTypes.contains(type) {
                matchedGarments.removeAll(where: { $0?.type == type })
            }
        }
    }
    
    // Append new garments to main array
    if criteria.lockedTypes.isEmpty {
        outfitGarments = matchedGarments
    } else {
        
        for matchedGarment in matchedGarments {
            
            if let type = matchedGarment?.type {
                
                if criteria.lockedTypes.contains(type) {
                    outfitGarments.append(criteria.previousGarments.first(where: { $0.type == type }))
                } else {
                    outfitGarments.append(matchedGarment)
                }
            }
        }
    }
    
    // Sort
    outfitGarments.sort { garment1, garment2 in
        
        guard let type1 = garment1?.type, let type2 = garment2?.type else {
            return false
        }
        
        return type1 < type2
    }
    
    // Remove nil values
    outfitGarments.removeAll(where: { $0 == nil })
    
    // Make sure it is not the same outfit, if it is should repeat method with a 5 count limit
    if criteria.previousGarments.count == outfitGarments.count && criteria.previousGarments == outfitGarments && criteria.lockedTypes.count != 5 && repeatCount <= 5 {
        return createOutfitWith(garments, criteria: criteria, repeatCount: repeatCount + 1)
    }
    
    return outfitGarments
}

func createOutfitV2With(_ allGarments: [Garment], criteria: OutfitCriteria, repeatCount: Int = 0) -> [Garment?] {
    
    var filteredGarments = allGarments
    var outfitGarments: [GarmentType: Garment?]  = [
        .Top: nil,
        .Bottom: nil,
        .Shoes: nil,
        .Hoodie: nil,
        .Jacket: nil,
    ]
    
    // Dresscode
    if !criteria.dressCode.contains(.Mixed) {
        for dressCode in criteria.dressCode {
            let newMatchingGarments = allGarments.filter({ $0.dressCode?.contains(dressCode) ?? false || $0.dressCode?.contains(.Mixed) ?? false })
            let set = Set(newMatchingGarments)
            filteredGarments = Array(set.union(filteredGarments))
        }
    }
    
    // Adjust probabilities
    if criteria.weather == .Warm {
        filteredGarments.removeAll(where: { ($0.type == .Hoodie || $0.type == .Jacket) && $0.overlayMatch != true })
        filteredGarments.removeAll(where: { $0.weather?.contains(.Lightweight) == true && $0.weather?.contains(.Warm) == false })
    }
    
    if criteria.weather == .Lightweight {
        filteredGarments.removeAll(where: { $0.weather?.contains(.Warm) == true && $0.weather?.contains(.Lightweight) == false })
    }
    
    let weatherAdjustedGarments = filteredGarments.filter({ $0.weather?.contains(criteria.weather) == true })
    
    filteredGarments = filteredGarments.adjustRandomProbabilities()
    for _ in 1...3 { filteredGarments.append(contentsOf: weatherAdjustedGarments) }
    
    // Get base
    let locked = criteria.previousGarments.filter({ criteria.lockedTypes.contains($0.type ?? .Top) })
    
    var baseGarment: Garment? = nil
    if let base = locked.first(where: { !Color.neutralColors.contains($0.mainColor ?? .neutral) }) {
        baseGarment = base
    } else if let base = locked.first {
        baseGarment = base
    }
    
    if baseGarment == nil {
        if criteria.weather == .Lightweight {
            baseGarment = filteredGarments.filter({ $0.type == .Top || $0.type == .Bottom }).randomElement()
        } else {
            baseGarment = filteredGarments.randomElement()
            
        }
    }
    
    guard let baseGarment = baseGarment, let baseGarmentType = baseGarment.type else {
        return []
    }
    
    outfitGarments[baseGarmentType] = baseGarment
    
    // Get rest of garments
    let percentage: Float = criteria.accuracy == .Broader ? 0.5 : criteria.accuracy == .Accurate ? 0.7 : 0.6
    var matches = filteredGarments.filter({ baseGarment.matchingPercentageWith($0) >= percentage })
    
    if baseGarment.type != .Bottom {
        if let bottom = locked.first(where: { $0.type == .Bottom }) ?? matches.filter({ $0.type == .Bottom }).randomElement() {
            outfitGarments[.Bottom] = bottom
            matches = matches.filter({ bottom.matchingPercentageWith($0) >= percentage })
        }
    }
    
    if baseGarment.type != .Jacket {
        if let jacket = locked.first(where: { $0.type == .Jacket }) ?? matches.filter({ $0.type == .Jacket }).randomElement() {
            outfitGarments[.Jacket] = jacket
            matches = matches.filter({ jacket.matchingPercentageWith($0) >= percentage })
        }
    }
    
    if baseGarment.type != .Hoodie {
        if let hoodie = locked.first(where: { $0.type == .Hoodie }) ?? matches.filter({ $0.type == .Hoodie }).randomElement() {
            outfitGarments[.Hoodie] = hoodie
            matches = matches.filter({ hoodie.matchingPercentageWith($0) >= percentage })
        }
    }
    
    if baseGarment.type != .Top {
        if let top = locked.first(where: { $0.type == .Top }) ?? matches.filter({ $0.type == .Top }).randomElement() {
            outfitGarments[.Top] = top
            matches = matches.filter({ top.matchingPercentageWith($0) >= percentage })
        }
    }
    
    if baseGarment.type != .Shoes {
        if let shoes = locked.first(where: { $0.type == .Shoes }) ?? matches.filter({ $0.type == .Shoes }).randomElement() {
            outfitGarments[.Shoes] = shoes
            matches = matches.filter({ shoes.matchingPercentageWith($0) >= percentage })
        }
    }
    
    // Add missing garments as neutral if possible
    for (type, garment) in outfitGarments {
        if garment == nil {
            outfitGarments[type] = filteredGarments.filter({ $0.type == type }).filter({ $0.mainColor == .neutral }).randomElement()
        }
    }
    
    // Overlay probability
    var overlayProbability: Double = 1/4
    switch criteria.weather {
    case .Neutral:
        overlayProbability = 1/4
        
    case .Midpoint:
        overlayProbability = 1/3
    case .Lightweight:
        overlayProbability = 0
    case .Warm:
        overlayProbability = 1
    }
    
    let randomOverlay = Int.random(in: 0...1)
    let matchingGarments = outfitGarments.compactMapValues({ $0 }).map({ $0.value })
    
    let noOverlayGarments = matchingGarments.filter({ $0.type == .Hoodie || $0.type == .Jacket }).filter({ $0.overlayMatch != true })
    let lockedGarmentsContainsNoOverlay = ((criteria.lockedTypes.contains(.Hoodie) || criteria.lockedTypes.contains(.Jacket)) && criteria.previousGarments.filter({ $0.type == .Hoodie || $0.type == .Jacket }).contains(where: { $0.overlayMatch != true }))
    if !noOverlayGarments.isEmpty || lockedGarmentsContainsNoOverlay {
        if (criteria.lockedTypes.contains(.Hoodie) || criteria.lockedTypes.contains(.Jacket)) && !(criteria.lockedTypes.contains(.Hoodie) && criteria.lockedTypes.contains(.Jacket)) {
            // Single overlay lock type, base on that
            if let overlayLockedType = criteria.lockedTypes.first(where: { $0 == .Hoodie || $0 == .Jacket }) {
                let inverted: GarmentType = overlayLockedType == .Jacket ? .Hoodie : .Jacket
                outfitGarments[inverted] = nil as Garment?
            }
        } else {
            if overlayProbability == 0 {
                outfitGarments[.Hoodie] = nil as Garment?
                outfitGarments[.Jacket] = nil as Garment?
            } else {
                // Random
                var type: GarmentType = randomOverlay == 0 ? .Jacket : .Hoodie
                
                // If base type is jacket, invert order
                if baseGarment.type == .Jacket {
                    type = .Hoodie
                }
                
                // If base type is hoodie, invert order
                if baseGarment.type == .Hoodie {
                    type = .Jacket
                }
                
                outfitGarments[type] = nil as Garment?
            }
        }
    } else {
        // Remove optional garments depending on random double
        if Double.random(in: 0.01...1) > overlayProbability {
            let type: GarmentType = randomOverlay == 0 ? .Hoodie : .Jacket
            if !criteria.lockedTypes.contains(type) {
                outfitGarments[type] = nil as Garment?
            }
        } else {
            if criteria.weather == .Neutral || criteria.weather == .Midpoint { overlayProbability = overlayProbability/2 }
        }
        
        if Double.random(in: 0.01...1) > overlayProbability {
            let type: GarmentType = randomOverlay == 0 ? .Jacket : .Hoodie
            if !criteria.lockedTypes.contains(type) {
                outfitGarments[type] = nil as Garment?
            }
        }
    }
    
    let outfitGarmentsValues = outfitGarments.compactMapValues({ $0 }).map({ $0.value })
    
    // Make sure it is not the same outfit, if it is should repeat method with a 5 count limit
    if criteria.previousGarments.count == outfitGarments.count && criteria.previousGarments == outfitGarmentsValues && criteria.lockedTypes.count != 5 && repeatCount <= 5 {
        return createOutfitWith(allGarments, criteria: criteria, repeatCount: repeatCount + 1)
    }
    
    return outfitGarmentsValues
}

func regenerateGarment(_ garment: Garment, from garments: [Garment], with accuracy: OutfitAccuracy) -> Garment? {
    
    guard let type = garment.type, let dressCode = garment.dressCode else {
        return nil
    }
    
    var filtered = garments.filter({ $0.type == type })
    for dressCode in dressCode {
        let newMatchingGarments = filtered.filter({ $0.dressCode?.contains(dressCode) ?? false || $0.dressCode?.contains(.Mixed) ?? false })
        let set = Set(newMatchingGarments)
        filtered = Array(set.union(filtered))
    }
    
    if filtered.count > 1 {
        // If garments count > 1, force garment to be different
        filtered = filtered.filter({ $0 != garment })
    }
    
    let criteria = OutfitCriteria(dressCode: dressCode, accuracy: accuracy)
    let matches = matchingGarmentsFrom(filtered, colors: [garment.hex_bri ?? [:]], criteria: criteria)
    
    return matches.filter({ $0.type == type && $0.disabled != true }).randomElement()
}

func generateOutfitsSuggestions(_ count: Int, with garments: [Garment], weather: GarmentWeather) -> [Outfit] {
    
    var garments = garments
    
    // prevent
    for type in [GarmentType.Top, GarmentType.Bottom, GarmentType.Shoes] {
        if garments.filter({ $0.type == type }).count < 2 {
            return []
        }
    }
    
    if weather == .Lightweight {
        garments.removeAll(where: { $0.type == .Hoodie || $0.type == .Jacket })
    }
    
    // Get dominant dress code
    var dressCode: GarmentDressCode = .Casual
    var dressCodeCount: [GarmentDressCode: Int] = [
        .Casual: 0,
        .Formal: 0,
        .Informal: 0,
        .SemiFormal: 0,
        .Mixed: 0
    ]
    
    var randomColors = [Color]()
    
    // loop through each user garment
    for garment in garments {
        
        for dressCode in garment.dressCode ?? [] {
            let count = dressCodeCount[dressCode] ?? 0
            dressCodeCount[dressCode] = count + 1
        }
        
        if let color = garment.mainColor {
            // get main color and append to random colors array, remove in case it is already in array to add again
            randomColors.removeAll(where: { $0 == color })
            randomColors.append(color)
        }
    }
    
    dressCode = dressCodeCount.sorted(by: { $0.1 > $1.1 }).map({ $0.0 }).first ?? .Casual
    garments = garments.filter({ $0.dressCode?.contains(dressCode) == true })
    
    // colors count
    var garmentColorsCount = randomColors.count - count
    // substract the count
    garmentColorsCount -= count
    
    // remove colors until there are only 3 random left
    if garmentColorsCount > 0 {
        for _ in 1...garmentColorsCount {
            randomColors.remove(at: Int.random(in: 0...(randomColors.count - 1)))
        }
    }
    
    var suggestedOutfits = [Outfit]()
    
    var counter = 1
    var upperLimit = count
    while counter <= upperLimit {
        if let base = garments.filter({ $0.mainColor == randomColors[counter - 1] }).randomElement(), let baseType = base.type {
            let criteria = OutfitCriteria(dressCode: [dressCode], accuracy: .Balanced, weather: weather, previousGarments: [base], lockedTypes: [baseType])
            let outfit = Outfit(name: "", dressCode: dressCode, uid: "", garments: createOutfitV2With(garments, criteria: criteria))
            
            if !outfit.containsMandatory() {
                if let newColor = Color.allCases.filter({ !randomColors.contains($0) }).randomElement() {
                    randomColors.append(newColor)
                    upperLimit += 1
                }
            } else {
                suggestedOutfits.append(outfit)
            }
        }
        
        counter += 1
    }
    
    return suggestedOutfits
}

extension [Garment] {
    func adjustRandomProbabilities() -> [Garment] {
        let garments = self
        if garments.isEmpty {
            return []
        }
        
        let wearCountAverage = Int(garments.map({ $0.wearCount }).compactMap({ $0 }).map({ Double($0) }).average())
        
        var newGarments = garments
        for garment in garments {
            // Add garment twice if garment wearCount is less than the global average
            if (garment.wearCount ?? 0) < wearCountAverage {
                newGarments.append(garment)
            }
            
            // Get garment average brightness
            if let avgBrightness = garment.averageBrightness {
                
                // Add garment twice if garment average brightness is adequated for user settings
                let skin = UserDefaultsManager.shared.getSkinTone(), height = UserDefaultsManager.shared.getUserHeight(), weight = UserDefaultsManager.shared.getUserWeight()
                
                // Skip proccess if user setting is average
                if skin != .tan {
                    // Lighter
                    if skin.order < 2 && avgBrightness > 0.5 { newGarments.append(garment) }
                    // Darker
                    if skin.order > 2 && avgBrightness < 0.5 { newGarments.append(garment) }
                }
                
                if height != .average {
                    // Shorter
                    if height.order < 2 && avgBrightness > 0.5 { newGarments.append(garment) }
                    // Taller
                    if height.order > 2 && avgBrightness < 0.5 { newGarments.append(garment) }
                }
                
                if weight != .average {
                    // Skinny
                    if weight.order < 2 && avgBrightness < 0.5 { newGarments.append(garment) }
                    // Thick
                    if weight.order > 2 && avgBrightness > 0.5 { newGarments.append(garment) }
                }
            }
        }
        
        return newGarments
    }
}

/*
   ==.---.
     |^   |  __
      /====\/  \
      |====|\../
      \====/
        \/
*/
