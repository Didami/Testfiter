//
//  CalendarService.swift
//  Outfiter
//
//  Created by Didami on 07/02/23.
//

// MARK: - PATENTED

import UIKit

public enum DateFormat: String {
    case month = "LLLL"
    case year = "yyyy"
    case full = "EEEE, MMMM d, yyyy"
}

final class CalendarService {
    
    public static let shared = CalendarService()
    private let calendar = Calendar.current
    
    public func plus(component: Calendar.Component, date: Date) -> Date {
        return calendar.date(byAdding: component, value: 1, to: date)!
    }
    
    public func minus(component: Calendar.Component, date: Date) -> Date {
        return calendar.date(byAdding: component, value: -1, to: date)!
    }
    
    public func dateString(date: Date, format: DateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: date)
    }
    
    public func daysInMonth(date: Date) -> Int {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    public func dayOf(date: Date) -> Int {
        let components = calendar.dateComponents([.day], from: date)
        return components.day!
    }
    
    public func monthOf(date: Date) -> Int {
        let components = calendar.dateComponents([.month], from: date)
        return components.month!
    }
    
    public func yearOf(date: Date) -> Int {
        let components = calendar.dateComponents([.year], from: date)
        return components.year!
    }
    
    public func firstOfMonth(date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
    public func weekDay(date: Date) -> Int {
        let components = calendar.dateComponents([.weekday], from: date)
        return components.weekday! - 1
    }
    
    public func isDateCurrent(date: Date) -> Bool {
        let currentDate = Date.currentDate
        let currentDay = dayOf(date: currentDate), dateDay = dayOf(date: date)
        let currentMonth = monthOf(date: currentDate), dateMonth = monthOf(date: date)
        let currentYear = yearOf(date: currentDate), dateYear = yearOf(date: date)
        
        if currentDay == dateDay && currentMonth == dateMonth && currentYear == dateYear {
            return true
        }
        
        return false
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
