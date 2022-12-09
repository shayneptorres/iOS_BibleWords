//
//  WordInstancePassageDetailsView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/14/22.
//

import SwiftUI

struct WordInstancePassageDetailsView: View {
    @Environment(\.managedObjectContext) var context
    
    var word: Bible.WordInfo
    var instance: Bible.WordInstance
    @State var showBibleReader = false
    
    var body: some View {
        List {
            VStack(alignment: .leading) {
                HStack {
                    Text("Word Details")
                        .bold()
                    Spacer()
                }
                Divider()
                
                HStack(alignment: .center) {
                    HStack {
                        Text("Surface:")
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                            .font(.subheadline)
                        Spacer()
                    }
                    .frame(width: 110)
                    VStack {
                        Text(instance.textSurface.lowercased())
                            .font(instance.language == .greek ? .bible24 : .bible32)
                    }
                }
                .padding(.bottom, 4)
                if instance.surface != instance.surfaceComponents {
                    HStack(alignment: .center) {
                        HStack {
                            Text("Components:")
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                                .font(.subheadline)
                            Spacer()
                        }
                        .frame(width: 110)
                        VStack {
                            Text(instance.surfaceComponents)
                                .font(instance.language == .greek ? .bible24 : .bible32)
                        }
                    }
                    .padding(.bottom, 4)
                }
                HStack(alignment: .center) {
                    HStack {
                        Text("Lemma:")
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                            .font(.subheadline)
                        Spacer()
                    }
                    .frame(width: 110)
                    VStack {
                        Text(instance.wordInfo.lemma)
                            .font(instance.language == .greek ? .bible24 : .bible32)
                    }
                }
                .padding(.bottom, 8)
                HStack(alignment: .top) {
                    HStack {
                        Text("Parsing:")
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                            .font(.subheadline)
                        Spacer()
                    }
                    .frame(width: 110)
                    VStack {
                        Text(instance.parsing)
                            .lineLimit(4)
                    }
                }
                .padding(.bottom)
                HStack(alignment: .top) {
                    HStack {
                        Text("Definintion:")
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                            .font(.subheadline)
                        Spacer()
                    }
                    .frame(width: 110)
                    VStack {
                        if let vocab = instance.wordInfo.vocabWord(context: context) {
                            Text(vocab.definition)
                        } else {
                            Text(instance.wordInfo.definition)
                        }
                    }
                    .padding(.bottom)
                }
                if !instance.interlinearStr.isEmpty {
                    HStack(alignment: .top) {
                        HStack {
                            Text("Translation:")
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                                .font(.subheadline)
                            Spacer()
                        }
                        .frame(width: 110)
                        VStack {
                            Text(instance.interlinearStr)
                                .lineLimit(4)
                        }
                    }
                    .padding(.bottom)
                }
            }
            VStack(alignment: instance.language == .greek ? .leading : .trailing) {
                Text(instance.wordInPassage) { string in
                    let attributedStr = instance.textSurface
                    if let range = string.range(of: attributedStr) { /// here!
                        string[range].foregroundColor = .accentColor
                    }
                }
                .font(instance.language.largeBibleFont)
            }
            Section {
                Button(action: {
                    showBibleReader = true
                }, label: {
                    Label("Read in Bible", systemImage: "book")
                })
            }
        }
        .fullScreenCover(isPresented: $showBibleReader) {
            NavigationView {
                BibleReadingView(passage: .constant(.init(book: instance.bibleBook, chapter: instance.chapter, verse: -1)))
            }
        }
        .navigationTitle(instance.prettyRefStr)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// extension to make applying AttributedString even easier
extension Text {
    init(_ string: String, configure: ((inout AttributedString) -> Void)) {
        var attributedString = AttributedString(string) /// create an `AttributedString`
        configure(&attributedString) /// configure using the closure
        self.init(attributedString) /// initialize a `Text`
    }
}

struct WordInPassageView_Previews: PreviewProvider {
    static var previews: some View {
        WordInstancePassageDetailsView(word: Bible.WordInfo.init([:]), instance: Bible.WordInstance.init(dict: [:]))
    }
}
