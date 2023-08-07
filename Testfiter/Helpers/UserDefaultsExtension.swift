//
//  UserDefaultsExtension.swift
//  Outfiter
//
//  Created by Didami on 07/08/22.
//

// MARK: - PATENTED

import Foundation
import UIKit
import StoreKit

final class ReviewService {
    
    static let shared = ReviewService()
    
    private let defaults = UserDefaults.standard
    
    private var lastRequest: Date? {
        get {
            return defaults.object(forKey: "ReviewService.lastRequest") as? Date
        }
        set {
            defaults.set(newValue, forKey: "ReviewService.lastRequest")
        }
    }
    
    private var oneWeekAgo: Date {
        return Calendar.current.date(byAdding: .day, value: -7, to: .currentDate)!
    }
    
    private var shouldRequestReview: Bool {
        if lastRequest == nil {
            return true
        } else if let lastRequest = self.lastRequest, lastRequest < oneWeekAgo {
            return true
        }
        
        return false
    }
    
    public func requestReview() {
        guard let keyWindow = UIApplication.keyWindow, let windowScene = keyWindow.windowScene, shouldRequestReview else { return }
        keyWindow.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            SKStoreReviewController.requestReview(in: windowScene)
            keyWindow.isUserInteractionEnabled = true
            self.lastRequest = .currentDate
        }
    }
}

protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"
    
    var errorDescription: String? {
        rawValue
    }
}

extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
            self.synchronize()
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }
    
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            self.synchronize()
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
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
