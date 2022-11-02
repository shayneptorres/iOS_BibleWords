//
//  DefaultVocabListSelectorView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/19/22.
//

import SwiftUI
import CoreData

struct DefaultVocabListSelectorView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    @State var showBuiltWordsList = false
    @State var builtWords: [Bible.WordInfo] = []
    @State var isBuilding = false
    @State var selectedListType = DefaultVocabListType.greek50
    @State var selectedLang: Language = .all
    
    var body: some View {
        NavigationStack {
            List {
                Picker("Language", selection: $selectedLang) {
                    Text("All").tag(Language.all)
                    Text("Greek").tag(Language.greek)
                    Text("Hebrew").tag(Language.hebrew)
                }.pickerStyle(.segmented)
                if selectedLang == .hebrew || selectedLang == .all {
                    Section {
                        ForEach(DefaultVocabListType.hebrewTypes, id: \.rawValue) { type in
                            Button(action: { onBuild(listType: type) }, label: {
                                HStack {
                                    Text(type.rowTitle)
                                    Spacer()
                                    Text("\(type.wordCount) words")
                                        .font(.subheadline)
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            })
                        }
                    } header: {
                        Text("Hebrew")
                    }
                }
                if selectedLang == .greek || selectedLang == .all {
                    Section {
                        ForEach(DefaultVocabListType.greekTypes, id: \.rawValue) { type in
                            Button(action: { onBuild(listType: type) }, label: {
                                HStack {
                                    Text(type.rowTitle)
                                    Spacer()
                                    Text("\(type.wordCount) words")
                                        .font(.subheadline)
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            })
                        }
                    } header: {
                        Text("Greek")
                    }
                }
            }
            .sheet(isPresented: .init(get: { !builtWords.isEmpty && showBuiltWordsList }, set: { _ in })) {
                BuiltWordsList()
            }
            .toolbar {
                Button(action: { presentationMode.wrappedValue.dismiss() }, label: {
                    Text("Dismiss")
                })
            }
            .navigationTitle("Preset Vocab Lists")
        }
    }
}

extension DefaultVocabListSelectorView {
    func onSave() {
        // save list
        CoreDataManager.transaction(context: context) {
            let list = VocabWordList(context: context)
            list.id = UUID().uuidString
            list.title = selectedListType.rowTitle
            list.details = ""
            list.createdAt = Date()
            
            let newRange = VocabWordRange.new(context: context, range: selectedListType.range)
            list.addToRanges(newRange)
   
            let vocabFetchRequest = NSFetchRequest<VocabWord>(entityName: "VocabWord")
            vocabFetchRequest.predicate = NSPredicate(format: "SELF.id IN %@", builtWords.map { $0.id })

            var matchingVocabWords: [VocabWord] = []
            do {
                matchingVocabWords = try context.fetch(vocabFetchRequest)
            } catch let err {
                print(err)
            }

            for word in matchingVocabWords {
                list.addToWords(word)
            }
            showBuiltWordsList = false
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func onBuild(listType: DefaultVocabListType) {
        isBuilding = true
        selectedListType = listType
        
        DispatchQueue.global().async {
            self.builtWords.removeAll()
            var words: Set<Bible.WordInfo> = []
            
            VocabListBuilder.buildVocabList(bookStart: listType.range.bookStart,
                                                 chapStart: listType.range.chapStart,
                                                 bookEnd: listType.range.bookEnd,
                                                 chapEnd: listType.range.chapEnd,
                                            occurrences: listType.range.occurrencesInt).forEach { words.insert($0) }
            
            DispatchQueue.main.async {
                self.builtWords = words.map { $0 }
                isBuilding = false
                showBuiltWordsList = true
            }
        }
    }
}

extension DefaultVocabListSelectorView {
    func BuiltWordsList() -> some View {
        NavigationStack {
            ZStack {
                List {
                    Text(selectedListType.rowTitle)
                    Section {
                        ForEach(builtWords) { word in
                            NavigationLink(value: word) {
                                WordInfoRow(wordInfo: word.bound())
                            }
                        }
                    } header: {
                        Text("\(builtWords.count) words")
                    }
                }
                VStack {
                    Spacer()
                    AppButton(text: "Save list") {
                        onSave()
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Bible.WordInfo.self) { word in
                WordInfoDetailsView(word: word.bound())
            }
            .toolbar {
                Button(action: { showBuiltWordsList = false }, label: { Text("Dismiss").bold() })
            }
            .interactiveDismissDisabled()
        }
    }
}

enum DefaultVocabListType: Int, CaseIterable {
    case greek500
    case greek200
    case greek150
    case greek100
    case greek50
    case greek20
    case greek15
    case greek10
    case greek5
    case greek2
    case greekAll
    case hebrew500
    case hebrew200
    case hebrew150
    case hebrew100
    case hebrew50
    case hebrew20
    case hebrew15
    case hebrew10
    case hebrew5
    case hebrewAll
    
    static var hebrewTypes: [DefaultVocabListType] = [
        .hebrew500,
        .hebrew200,
        .hebrew150,
        .hebrew100,
        .hebrew50,
        .hebrew20,
        .hebrew15,
        .hebrew10,
        .hebrew5,
        .hebrewAll
    ]
    
    static var greekTypes: [DefaultVocabListType] = [
        .greek500,
        .greek200,
        .greek150,
        .greek100,
        .greek50,
        .greek20,
        .greek15,
        .greek10,
        .greek5,
        .greek2,
        .greekAll
    ]
    
    var langStr: String {
        switch self {
        case .greek500, .greek200, .greek150, .greek100, .greek50, .greek20, .greek15, .greek10, .greek5, .greek2, .greekAll:
            return "Greek"
        case .hebrew500, .hebrew200, .hebrew150, .hebrew100, .hebrew50, .hebrew20, .hebrew15, .hebrew10, .hebrew5, .hebrewAll:
            return "Hebrew"
        }
    }
    
    var occurrence: Int {
        switch self {
        case .greek500, .hebrew500: return 500
        case .greek200, .hebrew200: return 200
        case .greek150, .hebrew150: return 150
        case .greek100, .hebrew100: return 100
        case .greek50, .hebrew50: return 50
        case .greek20, .hebrew20: return 20
        case .greek15, .hebrew15: return 15
        case .greek10, .hebrew10: return 10
        case .greek5, .hebrew5: return 5
        case .greek2: return 2
        case .greekAll, .hebrewAll: return 0
        }
    }
    
    var rowTitle: String {
        switch self {
        case .greekAll, .hebrewAll:
            return "All \(langStr) words"
        default:
            return "\(self.langStr) words occuring more than \(occurrence) times"
        }
    }
    
    var wordCount: Int {
        switch self {
        case .greek500:
            return 39
        case .greek200:
            return 79
        case .greek150:
            return 107
        case .greek100:
            return 171
        case .greek50:
            return 312
        case .greek20:
            return 638
        case .greek15:
            return 809
        case .greek10:
            return 1129
        case .greek5:
            return 1863
        case .greek2:
            return 3479
        case .greekAll:
            return 5342
        case .hebrew500:
            return 63
        case .hebrew200:
            return 161
        case .hebrew150:
            return 207
        case .hebrew100:
            return 302
        case .hebrew50:
            return 543
        case .hebrew20:
            return 1184
        case .hebrew15:
            return 1444
        case .hebrew10:
            return 1921
        case .hebrew5:
            return 2887
        case .hebrewAll:
            return 6089
        }
    }
    
    var range: BibleRange {
        switch self {
        case .greek500, .greek200, .greek150, .greek100, .greek50, .greek20, .greek15, .greek10, .greek5, .greek2, .greekAll:
            return .init(bookStart: 40, bookEnd: 66, chapStart: 1, chapEnd: 22, occurrencesTxt: "\(self.occurrence)")
        case .hebrew500, .hebrew200, .hebrew150, .hebrew100, .hebrew50, .hebrew20, .hebrew15, .hebrew10, .hebrew5, .hebrewAll:
            return .init(bookStart: 1, bookEnd: 39, chapStart: 1, chapEnd: 3, occurrencesTxt: "\(self.occurrence)")
        }
    }
}


struct DefaultVocabListSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        DefaultVocabListSelectorView()
    }
}
