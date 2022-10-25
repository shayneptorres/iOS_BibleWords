//
//  VocabListTypeInfoView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/24/22.
//

import SwiftUI

struct VocabListTypeInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            List {
                InfoImageTextRow(imageName: "text.book.closed.fill", boldText: "Bible Passage List", text: " is a list that allows you to study vocab words based on a specific bible passage or range of passages. You can enter any range of Bible books, chapters, and number of occurrences and then build a list with all words that fit the above mentioned criteria. This type of list is helpful if you are wanting to read through books of the bible")
                InfoImageTextRow(imageName: "list.bullet.rectangle.portrait.fill", boldText: "Default List", text: " is preset list that will allow you to study all words from the Old or New Testament that occur more than the given amount of times. This list is a good way to build up your core vocabulary of words that occur most often in the Bible")
                InfoImageTextRow(imageName: "hand.point.up.braille.fill", boldText: "Custom Word List", text: " is list that is not based on any bible passage range or number of occurences. Instead you can manually search for and add any Greek or Hebrew word. This type of list is great if you are working through a Grammar or textbook and they have specific vocabulary words that do not fit in the other category of lists.")
            }
            .navigationTitle("Vocab List Types")
            .toolbar {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Dismiss")
                })
            }
        }
    }
}

struct VocabListTypeInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VocabListTypeInfoView()
    }
}
