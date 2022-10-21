//
//  Time+Extensions.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/23/22.
//

import Foundation

extension Int {
    var seconds: Int { return self }
    var minutes: Int { return self * 60 }
    var hours: Int { return self * 60 * 60 }
    var days: Int { return self * 60 * 60 * 24 }
    var months: Int { return self * 60 * 60 * 24 * 30 }
    var years: Int { return self * 60 * 60 * 24 * 30 * 12 }
    
    var int16: Int16 { return Int16(self) }
    
    var toPrettyTime: String {
        var str = ""
        if self < 1.minutes {
            str = "\(self) sec"
            return self == 1 ? str : str + "s"
        } else if self < 1.hours {
            str = "\(self / 1.minutes) min"
            return (self / 1.minutes) == 1 ? str : str + "s"
        } else if self < 1.days {
            str = "\(self / 1.hours) hour"
            return (self / 1.hours) == 1 ? str : str + "s"
        } else if self < 1.months {
            str = "\(self / 1.days) day"
            return (self / 1.days) == 1 ? str : str + "s"
        } else if self < 1.years {
            str = "\(self / 1.months) month"
            return (self / 1.months) == 1 ? str : str + "s"
        } else {
            str = "\(self / 1.years) year"
            return (self / 1.years) == 1 ? str : str + "s"
        }
    }
    
    var toShortPrettyTime: String {
        if self < 1.minutes {
            return "\(self)s"
        } else if self < 1.hours {
            return "\(self / 1.minutes)min"
        } else if self < 1.days {
            return "\(self / 1.hours)hr"
        } else if self < 1.months {
            return "\(self / 1.days)dy"
        } else if self < 1.years {
            return "\(self / 1.months)mth"
        } else {
            return "\(self / 1.years)yr"
        }
    }
}
