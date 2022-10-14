//
//  Int+Extensions.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/13/22.
//

import Foundation

extension Int {
    var toInt16: Int16 {
        return Int16(self)
    }
    var toInt32: Int32 {
        return Int32(self)
    }
}

extension Int16 {
    var toInt: Int {
        return Int(self)
    }
    var toInt32: Int32 {
        return Int32(self)
    }
}

extension Int32 {
    var toInt: Int {
        return Int(self)
    }
    var toInt16: Int16 {
        return Int16(self)
    }
}

extension Double {
    var toInt: Int {
        return Int(self)
    }
}
