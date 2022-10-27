//  AppCard.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/26/22.
//

import SwiftUI

struct AppCard: ViewModifier {
    var height: CGFloat = 30
    var innerPadding: CGFloat = 16
    var outerPadding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .frame(minHeight: height)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, innerPadding)
            .padding(.vertical, 12)
            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: Design.defaultCornerRadius))
            .padding(.bottom, outerPadding)
    }
}

extension View {
    func appCard(height: CGFloat = 30, innerPadding: CGFloat = 16, outerPadding: CGFloat = 16) -> some View {
        modifier(AppCard(height: height, innerPadding: innerPadding, outerPadding: outerPadding))
    }
}
