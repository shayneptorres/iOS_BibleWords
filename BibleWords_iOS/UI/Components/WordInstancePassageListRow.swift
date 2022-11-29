//
//  WordInstancePassageListRow.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/28/22.
//

import SwiftUI

struct WordInstancePassageListRow: View {
    var instance: Bible.WordInstance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(instance.prettyRefStr)
                .font(.title3)
                .bold()
            VStack(alignment: instance.language == .greek ? .leading : .trailing) {
                Text(instance.wordInPassage) { string in
                    let attributedStr = instance.textSurface
                    if let range = string.range(of: attributedStr) { /// here!
                        string[range].foregroundColor = .accentColor
                    }
                }
                .font(instance.language.largeBibleFont)
            }
            .padding(.bottom, 4)
        }
    }
}

//struct WordInstancePassageListRow_Previews: PreviewProvider {
//    static var previews: some View {
//        WordInstancePassageListRow()
//    }
//}
