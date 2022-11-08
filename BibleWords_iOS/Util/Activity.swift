//
//  Activity.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/27/22.
//

import Foundation
import SwiftUI

protocol RecentActivity: Identifiable {
    var id: String { get }
    var type: ActivityType { get }
    var displayTitle: String { get }
    var displayDetail: String { get }
}

enum ActivityType: Int16 {
    case vocab
    case parsing
    case read
    case paradigm
    
    var title: String {
        switch self {
        case .vocab:
            return "Vocab List"
        case .parsing:
            return "Parsing List"
        case .read:
            return "Bible Reading"
        case .paradigm:
            return "Paradigm"
        }
    }
    
    var description: String {
        switch self {
        case .vocab:
            return "Studied Vocab"
        case .parsing:
            return "Practiced Parsing"
        case .read:
            return "Read the Bible"
        case .paradigm:
            return "Practiced Paradigms"
        }
    }
    
    var imageName: String {
        switch self {
        case .vocab:
            return "ic_vocab"
        case .parsing:
            return "rectangle.and.hand.point.up.left.filled"
        case .read:
            return "book"
        case .paradigm:
            return "lightbulb"
        }
    }
    
    var image: Image {
        switch self {
        case .vocab:
            return Image("ic_vocab")
                .renderingMode(.template)
        case .parsing:
            return Image("ic_parse")
                .renderingMode(.template)
        case .read:
            return Image(systemName: "book")
        case .paradigm:
            return Image(systemName: "lightbulb")
        }
    }
}
