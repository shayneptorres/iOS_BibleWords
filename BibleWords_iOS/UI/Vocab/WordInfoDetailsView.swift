//
//  WordInfoDetails.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/11/22.
//

import SwiftUI

struct WordInfoDetailsView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    @State var word: Bible.WordInfo
    @State var showForms = true
    @State var showAppearances = true
    @State var showEditWordView = true
    
    var body: some View {
        List {
            WordInfoHeaderSection(wordInfo: $word)
            Section {
                if showForms {
                    ForEach(word.parsingInfo.instances.sorted { $0.parsingStr < $1.parsingStr }) { info in
                        HStack {
                            Text(info.textSurface)
                                .font(info.language.meduimBibleFont)
                            Spacer()
                            Text(info.parsingStr)
                                .font(.footnote)
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                        }
                    }
                }
            } header: {
                HStack {
                    Text("\(word.parsingInfo.instances.count) Forms")
                    Spacer()
                    Button(action: { showForms.toggle() }, label: {
                        Image(systemName: showForms ? "chevron.up" : "chevron.down")
                    })
                }
            }
            Section {
                if showAppearances {
                    ForEach(word.instances) { instance in
                        NavigationLink(value: Paths.wordInstance(instance)) {
                            VStack(alignment: .leading) {
                                Text(instance.prettyRefStr)
                                    .bold()
                                    .padding(.bottom, 2)
                                Text(instance.textSurface)
                                    .font(instance.language.meduimBibleFont)
                                    .padding(.bottom, 4)
                                Text(instance.parsingStr)
                                    .font(.footnote)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                        }
                    }
                }
            } header: {
                HStack {
                    Text("\(word.instances.count) Appearances")
                    Spacer()
                    Button(action: { showAppearances.toggle() }, label: {
                        Image(systemName: showAppearances ? "chevron.up" : "chevron.down")
                    })
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Done", action: { presentationMode.wrappedValue.dismiss() })
            }
        }
    }
}

//struct WordInstancesView_Previews: PreviewProvider {
//    static var previews: some View {
//        WordInstancesView(word: .constant(.init([:])))
//    }
//}
