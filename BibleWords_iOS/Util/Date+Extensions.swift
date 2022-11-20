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
    
    var toShortPrettyDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/y h:mm a"
//        formatter.dateFormat = "M.d.y, h:mm a"
        return formatter.string(from: self)
    }
    
    var prettyTimeSinceNow: String {
        let timeSinceNow = timeIntervalSinceNow
        if timeSinceNow < 1.minutes.toDouble {
            return "< 1min"
        } else if timeSinceNow < 1.hours.toDouble {
            return "\(Int(timeSinceNow / 1.minutes.toDouble))min"
        } else if timeSinceNow == 1.hours.toDouble {
            return "1hr"
        } else if timeSinceNow > 1.hours.toDouble {
            let hours = Int(timeSinceNow / 1.hours.toDouble)
            var minutes = Int(timeSinceNow / 1.minutes.toDouble) - (60 * hours)
//            minutes = minutes - ()
            return "\(hours)hr and \(minutes)min"
        }
        return "Sometime"
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
