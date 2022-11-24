//
//  BuildVocabListView.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/11/22.
//

import SwiftUI
import CoreData
import Combine

typealias GroupedWordInfos = (chapter: Int, words: [Bible.WordInfo])

struct BuildVocabListView: View {
    enum Filter: CaseIterable {
        case all
        case new
        
        var title: String {
            switch self {
            case .all: return "All words"
            case .new: return "New words"
            }
        }
    }
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    @State var bibleRanges: [BibleRange] = [.init()]
    @State var prevBibleRanges: [BibleRange] = []
    @State var prevTextbookRanges: [TextbookRange] = []
    @State var builtWords: [Bible.WordInfo] = []
    @State var isBuilding = false
    @State var showBuiltWords = false
    @State var showTextbookPicker = false
    @State var buildWordsFilter = Filter.all
    
    var filteredBuiltWords: [Bible.WordInfo] {
        switch buildWordsFilter {
        case .all: return builtWords
        case .new: return builtWords.filter { $0.isNewVocab(context: context) }
        }
    }
    
    var body: some View {
        List {
            if bibleRanges.isEmpty {
                Text("You have not added any ranges yet. Tap the button below to get stared.")
                    .multilineTextAlignment(.center)
            }
            if !bibleRanges.isEmpty {
                BibleRangesView()
            }
            Section {
                Button(action: {
                    bibleRanges.append(.init())
                }, label: {
                    Text(bibleRanges.isEmpty ? "Add range" : "Add another range")
                })
            }
        }
        .navigationTitle("New Vocab List")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: { presentationMode.wrappedValue.dismiss() }, label: {
                    Text("Cancel")
                        .bold()
                })
            }
            ToolbarItemGroup(placement: .keyboard) {
                Button("Done") {
                    hideKeyboard()
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    onBuild()
                }, label: {
                    Label(isBuilding ? "Building..." : "Build list", systemImage: "hammer")
                })
                .labelStyle(.titleAndIcon)
            }
        }
        .sheet(isPresented: $showBuiltWords) {
            NavigationView {
                ZStack {
                    List {
                        Picker(selection: $buildWordsFilter, content: {
                            ForEach(Filter.allCases, id: \.title) { filter in
                                Text(filter.title).tag(filter)
                            }
                        }, label: {})
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.appBackground)
                        .buttonStyle(.borderless)
                        Section {
                            ForEach(filteredBuiltWords) { word in
                                VStack(alignment: .leading) {
                                    Text(word.lemma)
                                        .font(word.language.meduimBibleFont)
                                        .padding(.bottom, 4)
                                        .foregroundColor(.accentColor)
                                    Text(word.definition)
                                        .font(.subheadline)
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                        .multilineTextAlignment(.leading)
                                }
                            }
                        } header: {
                            Text("\(filteredBuiltWords.count) words")
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .principal) {
                        NavHeaderTitleDetailView(title: bibleRanges.title,
                                                 detail: bibleRanges.details)
                    }
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button(action: { showBuiltWords = false }, label: { Text("Dismiss").bold() })
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            showBuiltWords = false
                            onSave()
                        }, label: {
                            Label("Save", systemImage: "note.text.badge.plus")
                        })
                        .labelStyle(.titleAndIcon)
                    }
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .interactiveDismissDisabled(true)
    }
    
    func onRemove(range: BibleRange) {
        guard let index = bibleRanges.firstIndex(where: { $0.id == range.id }) else { return }
        bibleRanges.remove(at: index)
    }
    
    func onSave() {
        // save list
        CoreDataManager.transaction(context: context) {
            let list = VocabWordList(context: context)
            list.id = UUID().uuidString
            list.lastStudied = Date()
            list.createdAt = Date()
            
            // save ranges
            for range in bibleRanges {
                let newRange = VocabWordRange.new(context: context, range: range)
                list.addToRanges(newRange)
            }
            
            list.title = list.defaultTitle
            list.details = list.defaultDetails
            
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
            
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func onBuild() {
        isBuilding = true
        
        DispatchQueue.global().async {
            builtWords.removeAll()
            var words: Set<Bible.WordInfo> = []
            
            for range in bibleRanges {
                VocabListBuilder.buildVocabList(bookStart: range.bookStart,
                                                     chapStart: range.chapStart,
                                                     bookEnd: range.bookEnd,
                                                     chapEnd: range.chapEnd,
                                                occurrences: range.occurrencesInt).forEach { words.insert($0) }
            }
            
            builtWords = Array(words)
            prevBibleRanges = bibleRanges
            isBuilding = false
            showBuiltWords = true
        }
    }
}

extension BuildVocabListView {
    func BibleRangesView() -> some View {
        ForEach($bibleRanges) { range in
            BibleRangePickerView(range: range, onDelete: {
                withAnimation { onRemove(range: range.wrappedValue) }
            })
        }
    }
}

struct BibleRangePickerView: View {
    @Binding var range: BibleRange
    var onDelete: (() -> Void)?
    
    var body: some View {
        Section {
            VStack {
                HStack {
                    Text("Book start")
                        .font(.caption)
                        .foregroundColor(.init(uiColor: .secondaryLabel))
                    Spacer()
                    Text("Chapter start")
                        .font(.caption)
                        .foregroundColor(.init(uiColor: .secondaryLabel))
                }
                HStack {
                    Picker("", selection: $range.bookStart) {
                        ForEach(Bible.Book.allCases, id: \.rawValue) { book in
                            Text(book.title).tag(book.rawValue)
                        }
                    }
                    .onReceive([self.range.bookStart].publisher.first()) { value in
                        self.range.onRangeUpdated()
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    Spacer()
                    Picker("", selection: $range.chapStart) {
                        ForEach(Array(1...Bible.Book(rawValue: range.bookStart)!.chapterCount), id: \.self) { i in
                            Text("Ch \(i)").tag(i)
                        }
                    }
                    .onReceive([self.range.bookStart].publisher.first()) { value in
                        self.range.onRangeUpdated()
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
            }
            VStack {
                HStack {
                    Text("Book end")
                        .font(.caption)
                        .foregroundColor(.init(uiColor: .secondaryLabel))
                    Spacer()
                    Text("Chapter end")
                        .font(.caption)
                        .foregroundColor(.init(uiColor: .secondaryLabel))
                }
                HStack {
                    Picker("", selection: $range.bookEnd) {
                        ForEach(Array(range.bookStart...availableEndBook), id: \.self) { bookInt in
                            Text(Bible.Book(rawValue: bookInt)!.title).tag(bookInt)
                        }
                    }
                    .onReceive([self.range.bookStart].publisher.first()) { value in
                        self.range.onRangeUpdated()
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    Spacer()
                    Picker("", selection: $range.chapEnd) {
                        ForEach(Array(1...Bible.Book(rawValue: range.bookEnd)!.chapterCount), id: \.self) { i in
                            Text("Ch \(i)").tag(i)
                        }
                    }
                    .onReceive([self.range.bookStart].publisher.first()) { value in
                        self.range.onRangeUpdated()
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
            }
            HStack {
                Text("Words occurring more than:")
                Spacer()
                TextField("# times", text: $range.occurrencesTxt)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.trailing)
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                                    if let textField = obj.object as? UITextField {
                                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                                    }
                                }
            }
        } footer: {
            if onDelete != nil {
                HStack {
                    Spacer()
                    Button(action: { onDelete?() }, label: {
                        Image(systemName: "minus.circle")
                    })
                }
            }
        }
    }
    
    var availableEndBook: Int {
        if range.bookStart < 40 {
            // user selecting OT range
            return Bible.Book.malachi.rawValue
        }
        return Bible.Book.revelation.rawValue
    }
}

struct TextbookRangePickerView: View {
    @Binding var range: TextbookRange
    var onDelete: () -> Void
    
    var body: some View {
        Section {
            VStack {
                Text(range.info.shortName)
                    .padding(.bottom)
                HStack {
                    Text("Chapter start")
                        .font(.caption)
                        .foregroundColor(.init(uiColor: .secondaryLabel))
                    Spacer()
                    Text("Chapter End")
                        .font(.caption)
                        .foregroundColor(.init(uiColor: .secondaryLabel))
                }
                HStack {
                    Picker("", selection: $range.chapStart) {
                        ForEach(Array(1...21), id: \.self) { i in
                            Text("Ch \(i)").tag(i)
                        }
                    }
                    .onReceive([self.range.chapStart].publisher.first()) { value in
                        if range.chapEnd < range.chapStart {
                            range.chapEnd = range.chapStart
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    Spacer()
                    Picker("", selection: $range.chapEnd) {
                        ForEach(Array(1...range.info.chapCount), id: \.self) { i in
                            Text("Ch \(i)").tag(i)
                        }
                    }
                    .onReceive([self.range.chapStart].publisher.first()) { value in
                        if range.chapEnd < range.chapStart {
                            range.chapEnd = range.chapStart
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
            }
        } footer: {
            HStack {
                Spacer()
                Button(action: onDelete, label: {
                    Image(systemName: "minus.circle")
                })
            }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct BuildVocabListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BuildVocabListView()
        }
    }
}
