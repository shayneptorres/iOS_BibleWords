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
    var isPresentedModally = false
    @State var updater = false
    @State var suggestedLinkedWords: [Bible.WordInfo] = []
    @State var isSearchingSuggestedWords = false
    @State var showForms = false
    @State var showAppearances = true
    @State var showEditWordView = false
    @State var showExternalDictOptions = false
    
    var body: some View {
        List {
            WordInfoHeaderSection(wordInfo: $word)
            Section {
                Button(action: {
                    showExternalDictOptions = true
                }, label: {
                    Label("Search other definitions", systemImage: "mail.and.text.magnifyingglass")
                })
            }
            FormsAppearancesSection()
            Section {
                HStack {
                    Label("Current Interval: ", systemImage: "chart.bar")
                    Spacer()
                    if let vocabWord = word.vocabWord(context: context) {
                        Text("\(vocabWord.currIntervalString)")
                            .bold()
                            .foregroundColor(.accentColor)
                    } else {
                        Text("New")
                            .bold()
                            .foregroundColor(.accentColor)
                    }
                }
                NavigationLink(destination: {
                    List {
                        if (word.vocabWord(context: context)?.studySessionEntriesArr ?? []).isEmpty {
                            Text("There is no study data available for this word yet. When you begin to study it then data will show up here.")
                        } else {
                            Section {
                                WordProgressLineChart(intervals: .init(
                                    get: {
                                        (
                                            word.vocabWord(context: context)?.studySessionEntriesArr ?? []
                                        )
                                        .sorted {
                                            $0.createdAt ?? Date() > $1.createdAt ?? Date()
                                        }
                                        .map { $0.interval.toInt }
                                    },
                                    set: { _ in })
                                )
                                .frame(height: 300)
                            }
                            Section {
                                ForEach((word.vocabWord(context: context)?.studySessionEntriesArr ?? []).sorted {
                                    $0.createdAt ?? Date() > $1.createdAt ?? Date() }) { entry in
                                        HStack {
                                            if entry.wasNewWord {
                                                Image(systemName: "gift")
                                                    .font(.title)
                                            } else if entry.prevInterval < entry.interval {
                                                Image(systemName: "arrow.up.forward")
                                                    .foregroundColor(.green)
                                                    .font(.title)
                                            } else {
                                                Image(systemName: "arrow.down.forward")
                                                    .foregroundColor(.red)
                                                    .font(.title)
                                            }
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    if entry.wasNewWord {
                                                        Text("Learned")
                                                    } else {
                                                        Text("\(entry.intervalStr)")
                                                    }
                                                }
                                                Text(entry.createdAt?.toPrettyShortDayMonthYearTimeString ?? "")
                                                    .font(.caption)
                                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                                            }
                                            Spacer()
                                        }
                                    }
                            }
                        }
                    }
                    .navigationTitle("Study History")
                    .navigationBarTitleDisplayMode(.inline)
                }, label: {
                    Label("Study History", systemImage: "chart.xyaxis.line")
                })
            } header: {
                Text("Study Stats")
            }
        }

        .sheet(isPresented: $showEditWordView, content: {
//            VocabWordDefinitionView(vocabWord: word.vocabWord(context: context)) { updatedWord in
//                
//            }
        })
        .navigationTitle("Word Info")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                if isPresentedModally {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Dismiss")
                            .bold()
                    })
                } else {
                    
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    showEditWordView = true
                }, label: {
                    Image(systemName: "pencil.circle")
                })
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
    @ViewBuilder
    func FormsAppearancesSection() -> some View {
        Section {
            NavigationLink(destination: {
                List {
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
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(word.lemma)
                            .font(word.language.meduimBibleFont)
                    }
                }
            }, label: {
                Label(title: {
                    Text("\(word.parsingInfo.instances.count)")
                        .bold()
                        .foregroundColor(.accentColor)
                    +
                    Text(" forms")
                }, icon: {
                    Image(systemName: "eye")
                })
            })
            NavigationLink(destination: {
                List {
                    ForEach(word.instances) { instance in
                        NavigationLink(destination: {
                            WordInPassageView(word: instance.wordInfo.bound(), instance: instance.bound())
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(instance.prettyRefStr)
                                    .font(.title)
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
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(word.lemma)
                            .font(word.language.meduimBibleFont)
                    }
                }
            }, label: {
                Label(title: {
                    Text("\(word.instances.count)")
                        .bold()
                        .foregroundColor(.accentColor)
                    +
                    Text(" appearances")
                }, icon: {
                    Image(systemName: "book")
                })
            })
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
