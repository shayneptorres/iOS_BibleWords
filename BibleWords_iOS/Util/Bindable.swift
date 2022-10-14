//
//  Bindable.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/11/22.
//

import Foundation
import Combine
import SwiftUI

protocol Bindable {}
extension Bindable {
    func bound() -> Binding<Self> {
        return .init(get: { self }, set: { _ in })
    }
}

extension Bible.WordInfo: Bindable {}
extension Bible.WordInstance: Bindable {}
extension VocabWordList: Bindable {}
