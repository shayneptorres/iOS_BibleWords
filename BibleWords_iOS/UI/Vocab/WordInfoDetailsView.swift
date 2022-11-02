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
    @Binding var word: Bible.WordInfo
    @State var updater = false
    @State var suggestedLinkedWords: [Bible.WordInfo] = []
    @State var isSearchingSuggestedWords = false
    @State var showForms = true
    @State var showAppearances = true
    @State var showEditWordView = true
    
    var body: some View {
        List {
            WordInfoHeaderSection(wordInfo: $word)
            if word.vocabWord(context: context)?.wordType == .appProvided {
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
                            NavigationLink(value: AppPath.wordInstance(instance)) {
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
            } else {
                if word.vocabWord(context: context)?.relatedWordId == nil {
                    Section {
                        if suggestedLinkedWords.isEmpty {
                            Text("Searching for suggested related words...")
                        } else {
                            ForEach(suggestedLinkedWords) { suggestedWord in
                                Button(action: {
                                    CoreDataManager.transaction(context: context) {
                                        word.vocabWord(context: context)?.relatedWordId = suggestedWord.id
                                    }
                                    updater.toggle()
                                }, label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(suggestedWord.lemma)
                                            .font(suggestedWord.language.meduimBibleFont)
                                        Text(suggestedWord.definition)
                                            .font(.footnote)
                                            .foregroundColor(Color(uiColor: .secondaryLabel))
                                    }
                                })
                            }
                        }
                    } header: {
                        Text("Suggested Related Words")
                    }
                } else if let relatedWord = Bible.main.word(for: word.vocabWord(context: context)?.relatedWordId ?? "") {
                    Button(action: {
                        CoreDataManager.transaction(context: context) {
                            word.vocabWord(context: context)?.relatedWordId = nil
                        }
                        updater.toggle()
                    }, label: {
                        Text("Reset Related Word")
                    })
                    Section {
                        if showForms {
                            ForEach(relatedWord.parsingInfo.instances.sorted { $0.parsingStr < $1.parsingStr }) { info in
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
                            Text("\(relatedWord.parsingInfo.instances.count) Forms")
                            Spacer()
                            Button(action: { showForms.toggle() }, label: {
                                Image(systemName: showForms ? "chevron.up" : "chevron.down")
                            })
                        }
                    }
                    Section {
                        if showAppearances {
                            ForEach(relatedWord.instances) { instance in
                                NavigationLink(value: AppPath.wordInstance(instance)) {
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
                            Text("\(relatedWord.instances.count) Appearances")
                            Spacer()
                            Button(action: { showAppearances.toggle() }, label: {
                                Image(systemName: showAppearances ? "chevron.up" : "chevron.down")
                            })
                        }
                    }
                }
            }
        }
        .navigationTitle("Word Info")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Done", action: { presentationMode.wrappedValue.dismiss() })
            }
        }
        .onAppear {
            if let vocab = word.vocabWord(context: context) {
                if vocab.wordType == .userImported && vocab.relatedWordId == nil {
                    var results: [Bible.WordInfo] = []
                    isSearchingSuggestedWords = true
                    DispatchQueue.global().async {
                        results = Bible.main.greekLexicon.words()
                            .filter {
                                $0.lemma.strippingAccents.lowercased().contains(self.word.lemma.strippingAccents.lowercased())
                            }
                        results += Bible.main.hebrewLexicon.words()
                            .filter {
                                $0.lemma.strippingAccents.lowercased().contains(self.word.lemma.strippingAccents.lowercased()) ||
                                $0.lemma.strippingHebrewVowels.lowercased().contains(self.word.lemma.strippingAccents.lowercased())
                            }
                        results.sort {
                            $0.lemma.lowercased().strippingAccents.strippingHebrewVowels <
                                $1.lemma.lowercased().strippingAccents.strippingHebrewVowels
                        }
                        
                        DispatchQueue.main.async {
                            self.suggestedLinkedWords = results
                            self.isSearchingSuggestedWords = false
                        }
                    }
                }
            }
        }
    }
}

//struct WordInstancesView_Previews: PreviewProvider {
//    static var previews: some View {
//        WordInstancesView(word: .constant(.init([:])))
//    }
//}
