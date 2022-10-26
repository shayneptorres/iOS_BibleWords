//
//  Date+Extensions.swift
//  BibleWords
//
//  Created by Shayne Torres on 10/7/22.
//

import Foundation

extension Date {
    var toPrettyDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E MMM d, yyyy h:mm a"
        return formatter.string(from: self)
    }
    
    var toShortPrettyDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/y"
//        formatter.dateFormat = "M.d.y, h:mm a"
        return formatter.string(from: self)
    }
    
    static var startOfToday: Date {
        let cal = Calendar.current
        return cal.startOfDay(for: Date())
    }
    
    static var endOfToday: Date {
        let cal = Calendar.current
        return cal.startOfDay(for: Date()).addingTimeInterval(Double(24.hours))
    }
    
    func isSameDay(as date: Date) -> Bool {
        let cal = Calendar.current
        return cal.isDateInToday(date)
    }
    
//    static var endOfToday: Date {
//        return Date.startOfToday.addingTimeInterval()
//    }
}
