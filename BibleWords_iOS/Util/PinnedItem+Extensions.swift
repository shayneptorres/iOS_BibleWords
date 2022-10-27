//
//  PinnedItem+Extensions.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/27/22.
//

import Foundation


extension PinnedItem {
    var activityType: ActivityType {
        if self.vocabList != nil {
            return .vocab
        } else {
            return .parsing
        }
    }
}
