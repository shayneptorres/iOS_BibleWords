//
//  AppButton.swift
//  BibleWords
//
//  Created by Shayne Torres on 10/6/22.
//

import SwiftUI

enum ButtonType {
    case primary
    case secondary
}

struct AppButton: View {
    var text: String
    var systemImage: String?
    var type: ButtonType = .primary
    var height: CGFloat = 55
    var horizontalPadding: CGFloat = 16
    var action: (() -> ())
    
    var body: some View {
        Button(action: action, label: {
            if systemImage != nil {
                Label(text, systemImage: systemImage!)
                    .appButton(type: type, height: height)
                    .bold()
                    .padding(.horizontal, horizontalPadding)
            } else {
                Text(text)
                    .bold()
                    .appButton(type: type, height: height)
                    .padding(.horizontal, horizontalPadding)
            }
        })
    }
}

struct AppButtonModifier: ViewModifier {
    let buttonType: ButtonType
    let width: CGFloat
    let height: CGFloat
    
    var textColor: Color {
        switch buttonType {
        case .primary:
            return .white
        case .secondary:
            return .accentColor
        }
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .frame(maxWidth: width)
            .frame(height: height)
            .background(btbBackground())
            .shadow(radius: 0.5)
    }
    
    func btbBackground() -> some View {
        if buttonType == .secondary {
            return AnyView(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: 2)
                    .foregroundColor(.accentColor)
                    .background(Color.white)
                    .cornerRadius(8)
            )
        } else {
            return AnyView(
                RoundedRectangle(cornerRadius: 8)
                    .background(Color.accentColor)
                    .cornerRadius(8)
            )
        }
    }
}

extension Label {
    func appButton(type: ButtonType = .primary, width: CGFloat = .infinity, height: CGFloat = 55) -> some View {
        modifier(AppButtonModifier(buttonType: type, width: width, height: height))
    }
}

extension Text {
    func appButton(type: ButtonType = .primary, width: CGFloat = .infinity, height: CGFloat = 55) -> some View {
        modifier(AppButtonModifier(buttonType: type, width: width, height: height))
    }
}

extension Image {
    func appButton(type: ButtonType = .primary, width: CGFloat = .infinity, height: CGFloat = 45) -> some View {
        modifier(AppButtonModifier(buttonType: type, width: width, height: height))
    }
}

//struct AppButton_Previews: PreviewProvider {
//    static var previews: some View {
////        AppButton()
//    }
//}
