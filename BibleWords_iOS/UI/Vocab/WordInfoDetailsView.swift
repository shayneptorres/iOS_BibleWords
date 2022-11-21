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
    @State var showForms = false
    @State var showAppearances = true
    @State var showEditWordView = true
    @State var showExternalDictOptions = false
    
    var body: some View {
        List {
            WordInfoHeaderSection(wordInfo: $word) {
                showExternalDictOptions = true
            }
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
        }
        .navigationTitle("Word Info")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AppPath.self) { path in
            switch path {
            case .wordInstance(let instance):
                WordInPassageView(word: instance.wordInfo.bound(), instance: instance.bound())
            default:
                Text("🫥")
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Done", action: { presentationMode.wrappedValue.dismiss() })
            }
        }
        .confirmationDialog("Search External Dictionaries", isPresented: $showExternalDictOptions, actions: {
            ForEach(getAvailableExternalDicts(), id: \.name) { dict in
                Button(dict.name, action: {
                    openExternalLink(url: dict.url)
                })   
            }
        }, message: {
            Text("Which External Dictionary would you like to view for this word?")
        })
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

extension WordInfoDetailsView {
    struct ExternalDict {
        let name: String
        let url: URL
    }
    
    func getAvailableExternalDicts() -> [ExternalDict] {
        
        var externalDicts: [ExternalDict] = []
        
        if word.language == .greek {
            let liddleScott = "https://ref.ly/logosres/lsj?hw=\(word.lemma.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
            if let url = URL(string: liddleScott) {
                if UIApplication.shared.canOpenURL(url) {
                    externalDicts.append(.init(name: "Liddell Scott", url: url))
                }
            }
            
            let bdag = "https://ref.ly/logosres/bdag?hw=\(word.lemma.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
            if let url = URL(string: bdag) {
                if UIApplication.shared.canOpenURL(url) {
                    externalDicts.append(.init(name: "BDAG", url: url))
                }
            }
        } else {
            let halot = "https://ref.ly/logosres/hal?hw=\(word.lemma.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
            if let url = URL(string: halot) {
                if UIApplication.shared.canOpenURL(url) {
                    externalDicts.append(.init(name: "HALOT", url: url))
                }
            }
        }
        
        return externalDicts
    }
    
    func openExternalLink(url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Cannot open link")
        }
    }
}

//struct WordInstancesView_Previews: PreviewProvider {
//    static var previews: some View {
//        WordInstancesView(word: .constant(.init([:])))
//    }
//}
