//
//  LiveActivity+Shareable.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/26/22.
//

import Foundation
import ActivityKit
import SwiftUI

struct StudyAttributes: ActivityAttributes {
    typealias StudyState = ContentState
     
    public struct ContentState: Codable, Hashable {
        var id: String
        var date: Date
        var text: String
        var def: String
        var displayModeInt = 0
        var dueCount = 0
        var newCount = 0
    }
    
    var studyListName: String
}

