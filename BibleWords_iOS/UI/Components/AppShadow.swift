//
//  AppShadow.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/26/22.
//

import SwiftUI

struct AppShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.1), radius: 15)
    }
}

extension View {
    func appShadow() -> some View {
        modifier(AppShadow())
    }
}
