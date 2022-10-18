//
//  WordDetailsView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/17/22.
//

import SwiftUI

struct WordDetailsView: View {
    @Binding var wordInstance: Bible.WordInstance
    var onInfo: () -> Void
    var onClose: () -> Void
    private let bibleWordFont = Font.bible32
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text("Word Details")
                        .bold()
                    Button(action: onInfo, label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16))
                    })
                    Spacer()
                    Button(action: onClose, label: {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 16))
                    })
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
                        Text(wordInstance.rawSurface)
                            .font(bibleWordFont)
                    }
                }
                .padding(.bottom, 4)
                if wordInstance.surface != wordInstance.rawSurface {
                    HStack(alignment: .center) {
                        HStack {
                            Text("Components:")
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                                .font(.subheadline)
                            Spacer()
                        }
                        .frame(width: 110)
                        VStack {
                            Text(wordInstance.surface)
                                .font(bibleWordFont)
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
                        Text(wordInstance.wordInfo.lemma)
                            .font(bibleWordFont)
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
                        Text(wordInstance.parsing)
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
                        Text(wordInstance.wordInfo.definition)
                            .lineLimit(4)
                    }
                }
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Design.defaultCornerRadius))
            .padding(.horizontal, 20)
            .padding(.bottom, 4)
            .transition(.move(edge: .bottom))
        }
    }
}

//struct WordDetailsVoew_Previews: PreviewProvider {
//    static var previews: some View {
//        WordDetailsView(wordInstance: .constant())
//    }
//}
