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
    
    static var startOfToday: Date {
        let cal = Calendar.current
        return cal.startOfDay(for: Date())
    }
    
//    static var endOfToday: Date {
//        return Date.startOfToday.addingTimeInterval()
//    }
}
