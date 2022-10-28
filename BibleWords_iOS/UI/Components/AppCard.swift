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
    var backgroundColor: Color = Color(uiColor: .secondarySystemGroupedBackground)
    func body(content: Content) -> some View {
        content
            .frame(minHeight: height)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, innerPadding)
            .padding(.vertical, 12)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: Design.defaultCornerRadius))
//            .appShadow()
            .padding(.bottom, outerPadding)
    }
}

extension View {
    func appCard(height: CGFloat = 30, innerPadding: CGFloat = 16, outerPadding: CGFloat = 16, backgroundColor: Color = Color(uiColor: .secondarySystemGroupedBackground)) -> some View {
        modifier(AppCard(height: height, innerPadding: innerPadding, outerPadding: outerPadding, backgroundColor: backgroundColor))
    }
}
