//
//  InfoImageTextRow.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/24/22.
//

import SwiftUI

struct InfoImageTextRow: View {
    var imageName: String
    var boldText: String?
    var text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: imageName)
                .font(.title)
                .foregroundColor(.accentColor)
                .padding(.trailing)
            if boldText != nil {
                Group {
                    Text(boldText!)
                        .bold()
                    +
                    Text(text)
                }
                .multilineTextAlignment(.leading)
            } else {
                Text(text)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

struct InfoImageTextRow_Previews: PreviewProvider {
    static var previews: some View {
        InfoImageTextRow(imageName: "", text: "")
    }
}
