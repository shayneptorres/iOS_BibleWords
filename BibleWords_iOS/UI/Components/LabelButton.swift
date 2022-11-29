//
//  LabelButton.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/28/22.
//

import SwiftUI

struct LabelButton: View {
    var title: String
    var systemImage: String
    var action: () -> Void
    var body: some View {
        Button(action: {
            action()
        }, label: {
            Label(title, systemImage: systemImage)
        })
    }
}

struct LabelButton_Previews: PreviewProvider {
    static var previews: some View {
        LabelButton(title: "", systemImage: "") {}
    }
}
