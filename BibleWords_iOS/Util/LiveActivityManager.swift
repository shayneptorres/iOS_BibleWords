//
//  LiveActivityManager.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/26/22.
//

import Foundation
import ActivityKit

@available(iOS, introduced: 16.1)
class LiveActivityMonitor {
    static var main = LiveActivityMonitor()
    var studyActivity: Activity<StudyAttributes>?
}
