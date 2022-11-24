//
//  TextbookSelectorView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/14/22.
//

import SwiftUI

struct TextbookSelectorView: View {
    @Environment(\.presentationMode) var presentationMode
    var onSelect: (API.Source.Info) -> Void
    var body: some View {
        NavigationView {
            List(API.Source.Info.textbookInfos) { textbook in
                VStack {
                    Button(action: {
                        onSelect(textbook)
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Label(textbook.longName, systemImage: "book.closed")
                            .multilineTextAlignment(.leading)
                    })
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }, label: { Text("Cancel").bold() })
                }
            }
            .navigationTitle("Select Textbook")
        }
    }
}

struct TextbookSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        TextbookSelectorView(onSelect: { _ in })
    }
}
