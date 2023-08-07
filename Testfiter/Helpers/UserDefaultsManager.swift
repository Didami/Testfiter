//
//  UserDefaultsManager.swift
//  Outfiter
//
//  Created by Didami on 07/08/22.
//

// MARK: - PATENTED

import Foundation
import UIKit

public enum UserDefaultsKeys: String {
    case garments
    case outfits
    case weather
    case calendar
}

final class UserDefaultsManager {
    
    public static let shared = UserDefaultsManager()
    
    let userDefaults = UserDefaults.standard
    
}

// MARK: - Garments
extension UserDefaultsManager {
    
    public enum UserDefaultsManagerErrors: Error {
        case emptyArray
        case notGold
    }
    
    public func fetchGarments(completion: @escaping(Result<[Garment], Error>) -> Void) {
        
        do {
            let garments = try userDefaults.getObject(forKey: UserDefaultsKeys.garments.rawValue, castTo: [Garment].self)
            
            if garments.isEmpty {
                completion(.failure(UserDefaultsManagerErrors.emptyArray))
                return
            }
            
            completion(.success(garments))
            
        } catch let error {
            completion(.failure(error))
        }
    }
    
    public func insertGarment(_ garment: Garment, completion: @escaping (_ success: Bool) -> ()) {
        
        self.fetchGarments { result in
            
            switch result {
            case .success(var garments):
                
                garments.removeAll(where: { $0.uid == garment.uid })
                garments.append(garment)
                
                do {
                    try self.userDefaults.setObject(garments, forKey: UserDefaultsKeys.garments.rawValue)
                    completion(true)
                } catch {
                    completion(false)
                }
                
            case .failure(let err):
                
                if err.localizedDescription == ObjectSavableError.unableToDecode.rawValue || err.localizedDescription == ObjectSavableError.noValue.rawValue || err.localizedDescription == UserDefaultsManagerErrors.emptyArray.localizedDescription {
                    
                    // NO VALUE FOR KEY OR ARRAY IS EMPTY
                    // SET VALUE
                    do {
                        try self.userDefaults.setObject([garment], forKey: UserDefaultsKeys.garments.rawValue)
                        completion(true)
                    } catch {
                        completion(false)
                    }
                    return
                }
                
                completion(false)
            }
        }
    }
    
    public func removeGarment(with uid: String, completion: @escaping (_ success: Bool) -> ()) {
        
        self.fetchGarments { result in
            
            switch result {
            case .success(var garments):
                
                garments.removeAll(where: { $0.uid == uid })
                
                self.fetchOutfits { result in
                    
                    switch result {
                    case .success(var outfits):
                        
                        outfits.removeAll(where: { $0.garments().contains(where: { $0?.uid == uid }) })
                        
                        self.fetchCalendar { result in
                            
                            switch result {
                            case .success(var calendar):
                                
                                calendar.forEach { date, outfit in
                                    if outfit.garments().contains(where: { $0?.uid == uid }) {
                                        calendar.removeValue(forKey: date)
                                    }
                                }
                                
                                do {
                                    try self.userDefaults.setObject(garments, forKey: UserDefaultsKeys.garments.rawValue)
                                    try self.userDefaults.setObject(outfits, forKey: UserDefaultsKeys.outfits.rawValue)
                                    try self.userDefaults.setObject(calendar, forKey: UserDefaultsKeys.calendar.rawValue)
                                    completion(true)
                                } catch {
                                    completion(false)
                                }
                                
                            case .failure(_):
                                do {
                                    try self.userDefaults.setObject(garments, forKey: UserDefaultsKeys.garments.rawValue)
                                    try self.userDefaults.setObject(outfits, forKey: UserDefaultsKeys.outfits.rawValue)
                                    completion(true)
                                } catch {
                                    completion(false)
                                }
                            }
                        }
                        
                    case .failure(_):
                        
                        do {
                            try self.userDefaults.setObject(garments, forKey: UserDefaultsKeys.garments.rawValue)
                            completion(true)
                        } catch {
                            completion(false)
                        }
                    }
                }
            case .failure(_):
                completion(false)
            }
        }
    }
    
    public func fetchWearCountForGarment(_ garment: Garment?) -> Int {
        var count = 0
        guard let garmentUid = garment?.uid else {
            return count
        }
        
        self.fetchGarments { result in
            switch result {
            case .success(let garments):
                if let wearCount = garments.first(where: { $0.uid == garmentUid })?.wearCount { count = wearCount }
            case .failure(_):
                count = 0
            }
        }
        
        return count
    }
    
    public func increaseWearCount(by sum: Int, for garment: Garment?, completion: @escaping (_ success: Bool) -> ()) {
        guard let modifiedGarment = garment else {
            completion(false)
            return
        }
        
        let wearCount = self.fetchWearCountForGarment(modifiedGarment)
        modifiedGarment.wearCount = wearCount + sum
        
        self.insertGarment(modifiedGarment) { success in
            completion(success)
        }
    }
    
    public func fetchColors() -> [[String: Float]] {
        
        var colors = [[String: Float]]()
        
        self.fetchGarments { result in
            switch result {
            case .success(let garments):
                
                colors = garments.map({ $0.hex_bri }).compactMap({ $0 })
                
            case .failure(_):
                colors = [[:]]
            }
        }
        
        return colors
    }
}

// MARK: - Outfits
extension UserDefaultsManager {
    
    public func fetchOutfits(completion: @escaping(Result<[Outfit], Error>) -> Void) {
        
        do {
            let outfits = try userDefaults.getObject(forKey: UserDefaultsKeys.outfits.rawValue, castTo: [Outfit].self)
            
            completion(.success(outfits))
            
        } catch let error {
            completion(.failure(error))
        }
    }
    
    public func insertOutfit(_ outfit: Outfit, completion: @escaping (_ success: Bool) -> ()) {
        
        self.fetchOutfits { result in
            
            switch result {
            case .success(var outfits):
                
                outfits.removeAll(where: { $0.uid == outfit.uid })
                outfits.append(outfit)
                
                do {
                    try self.userDefaults.setObject(outfits, forKey: UserDefaultsKeys.outfits.rawValue)
                    completion(true)
                } catch {
                    completion(false)
                }
                
            case .failure(let err):
                
                if err.localizedDescription == ObjectSavableError.unableToDecode.rawValue || err.localizedDescription == ObjectSavableError.noValue.rawValue || err.localizedDescription == UserDefaultsManagerErrors.emptyArray.localizedDescription {
                    
                    // NO VALUE FOR KEY OR ARRAY IS EMPTY
                    // SET VALUE
                    do {
                        try self.userDefaults.setObject([outfit], forKey: UserDefaultsKeys.outfits.rawValue)
                        completion(true)
                    } catch {
                        completion(false)
                    }
                    return
                }
                
                completion(false)
            }
        }
    }
    
    public func removeOutfit(with uid: String, completion: @escaping (_ success: Bool) -> ()) {
        
        self.fetchOutfits { result in
            
            switch result {
            case .success(var outfits):
                
                outfits.removeAll(where: { $0.uid == uid })
                
                do {
                    try self.userDefaults.setObject(outfits, forKey: UserDefaultsKeys.outfits.rawValue)
                    completion(true)
                } catch {
                    completion(false)
                }
                
            case .failure(_):
                completion(false)
            }
        }
    }
}

// MARK: - Calendar
extension UserDefaultsManager {
    
    public func fetchCalendar(completion: @escaping(Result<[String: Outfit], Error>) -> Void) {
        // Premium feature
        if !UserDefaultsManager.shared.isGoldUser() {
            completion(.failure(UserDefaultsManagerErrors.notGold))
            return
        }
        
        do {
            let dict = try userDefaults.getObject(forKey: UserDefaultsKeys.calendar.rawValue, castTo: [String: Outfit].self)
            
            completion(.success(dict))
            
        } catch let error {
            completion(.failure(error))
        }
    }
    
    public func fetchOutfitForDate(_ date: OutfitDate) -> Outfit? {
        // Premium feature
        if !UserDefaultsManager.shared.isGoldUser() { return nil }
        
        var outfit: Outfit?
        
        self.fetchCalendar { result in
            switch result {
            case .success(let dict):
                outfit = dict[date.string()]
            case .failure(_):
                outfit = nil
            }
        }
        
        return outfit
    }
    
    public func insertOutfitToCalendar(_ outfit: Outfit, date: OutfitDate, completion: @escaping (_ success: Bool) -> ()) {
        // Premium feature
        if !UserDefaultsManager.shared.isGoldUser() {
            completion(false)
            return
        }
        
        self.fetchCalendar { result in
            
            switch result {
            case .success(var dict):
                
                if dict[date.string()] != nil {
                    self.removeOutfitFromCalendar(date: date) { _ in
                        
                        // Loop through each new garment in new outfit
                        for garment in outfit.garments().compactMap({ $0 }) {
                            self.increaseWearCount(by: 1, for: garment) { success in
                                if !success { completion(false) }
                            }
                        }
                        
                        dict[date.string()] = outfit
                        
                        do {
                            try self.userDefaults.setObject(dict, forKey: UserDefaultsKeys.calendar.rawValue)
                            UserDefaultsManager.shared.setLastDate(.currentDate)
                            completion(true)
                        } catch {
                            completion(false)
                        }
                    }
                    return
                }
                
                // Loop through each new garment in new outfit
                for garment in outfit.garments().compactMap({ $0 }) {
                    self.increaseWearCount(by: 1, for: garment) { success in
                        if !success { completion(false) }
                    }
                }
                
                dict[date.string()] = outfit
                
                do {
                    try self.userDefaults.setObject(dict, forKey: UserDefaultsKeys.calendar.rawValue)
                    UserDefaultsManager.shared.setLastDate(.currentDate)
                    completion(true)
                } catch {
                    completion(false)
                }
                
            case .failure(let err):
                
                if err.localizedDescription == ObjectSavableError.unableToDecode.rawValue || err.localizedDescription == ObjectSavableError.noValue.rawValue || err.localizedDescription == UserDefaultsManagerErrors.emptyArray.localizedDescription {
                    
                    // NO VALUE FOR KEY OR ARRAY IS EMPTY
                    // SET VALUE
                    do {
                        try self.userDefaults.setObject([date.string(): outfit], forKey: UserDefaultsKeys.calendar.rawValue)
                        completion(true)
                    } catch {
                        completion(false)
                    }
                    return
                }
                
                completion(false)
            }
        }
    }
    
    public func removeOutfitFromCalendar(date: OutfitDate, completion: @escaping (_ success: Bool) -> ()) {
        // Premium feature
        if !UserDefaultsManager.shared.isGoldUser() {
            completion(false)
            return
        }
        
        self.fetchCalendar { result in
            
            switch result {
            case .success(var dict):
                
                guard let outfit = dict[date.string()] else {
                    completion(false)
                    return
                }
                
                for garment in outfit.garments().compactMap({ $0 }) {
                    self.increaseWearCount(by: -1, for: garment) { success in
                        if !success { completion(false) }
                    }
                }
                
                dict.removeValue(forKey: date.string())
                
                do {
                    try self.userDefaults.setObject(dict, forKey: UserDefaultsKeys.calendar.rawValue)
                    completion(true)
                } catch {
                    completion(false)
                }
                
            case .failure(_):
                completion(false)
            }
        }
    }
}

extension Notification.Name {
    static let premiumUserStatusChanged = Notification.Name("PremiumUserStatusChanged")
}

// MARK: - Settings
extension UserDefaultsManager {
    
    public func isFirstLaunch() -> Bool {
        return !userDefaults.bool(forKey: "not_first_launch")
    }
    
    public func isGoldUser() -> Bool {
        return userDefaults.bool(forKey: "is_gold")
    }
    
    public func setGoldUser() {
        setBoolean(with: "is_gold", to: true)
        NotificationCenter.default.post(name: .premiumUserStatusChanged, object: nil)
    }
    
    public func lastDate() -> Date {
        return (userDefaults.value(forKey: "last_date") as? Date) ?? .currentDate
    }
    
    public func setLastDate(_ date: Date) {
        userDefaults.set(date, forKey: "last_date")
    }
    
    public func setBoolean(with id: String, to bool: Bool) {
        userDefaults.set(bool, forKey: id)
    }
    
    public func getBoolean(with id: String) -> Bool {
        return userDefaults.bool(forKey: id)
    }
    
    public func setFloat(with id: String, value: Float) {
        userDefaults.set(value, forKey: id)
    }
    
    public func getFloat(with id: String) -> Float {
        return userDefaults.float(forKey: id)
    }
    
    // MARK: User settings
    public func getUserHeight() -> Height {
        return getFloat(with: "height").toHeight()
    }
    
    public func getUserWeight() -> Weight {
        return getFloat(with: "weight").toWeight()
    }
    
    public func getSkinTone() -> SkinTone {
        let value = getFloat(with: "skin_tone")
        let roundedValue = round(value * 10) / 10
        return roundedValue.toSkinTone()
    }
}

// MARK: - Image
final class LocalImageManager {
    
    public static let shared = LocalImageManager()
    
    public func saveImage(_ image: UIImage, uid: String, shouldReduce: Bool = true, completion: @escaping (_ success: Bool) -> ()) {
        
        var modImage = image
        
        // reduce size
        let highestQuality = UserDefaultsManager.shared.getBoolean(with: "highest_image_quality")
        
        let multiplier = highestQuality || !shouldReduce ? 1.0 : 0.6
        let newSize = CGSize(width: image.size.width * multiplier, height: image.size.height * multiplier)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        modImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // save
        guard let data = modImage.pngData() else {
            completion(false)
            return
        }
        
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            completion(false)
            return
        }
        
        do {
            try data.write(to: directory.appendingPathComponent("\(uid).png")!)
            completion(true)
        } catch {
            print(error.localizedDescription)
            completion(false)
        }
    }

    public func getSavedImage(uid: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("\(uid).png").path)
        }
        return nil
    }

    public func deleteSavedImage(uid: String, completion: @escaping (_ success: Bool) -> ()) {
        
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            
            do {
                try FileManager.default.removeItem(atPath: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("\(uid).png").path)
                completion(true)
            } catch {
                completion(false)
            }
        }
    }
}

extension LocalImageManager {
    
    public func removeBackgrounds(completion: @escaping (_ success: Bool) -> ()) {
        UserDefaultsManager.shared.fetchGarments { result in
            switch result {
            case .success(let fetched):
                
                let filtered = fetched.filter({ $0.hasImage() })
                if filtered.isEmpty {
                    completion(false)
                    return
                }
                
                for garment in filtered {
                    if let uid = garment.uid, let img = self.getSavedImage(uid: uid) {
                        let newImg = BackgroundRemoval().removeBackground(image: img)
                        self.saveImage(newImg, uid: uid) { success in
                            if !success {
                                completion(false)
                                return
                            }
                        }
                    }
                }
                
                completion(true)
                
            case .failure(_):
                completion(false)
            }
        }
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
