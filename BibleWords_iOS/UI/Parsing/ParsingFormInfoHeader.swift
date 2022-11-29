//
//  ParsingFormInfoHeader.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/29/22.
//

import SwiftUI

struct ParsingFormInfoHeader: View {
    @Environment(\.managedObjectContext) var context
    var instance: Bible.WordInstance
    
    var body: some View {
        Section {
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
                            .font(instance.language.meduimBibleFont)
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
                                .font(instance.language.meduimBibleFont)
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
                            .font(instance.language.meduimBibleFont)
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
                }
            }
        }
    }
}

//struct ParsingFormInfoHeader_Previews: PreviewProvider {
//    static var previews: some View {
//        ParsingFormInfoHeader()
//    }
//}
