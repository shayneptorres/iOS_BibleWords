//
//  BuildVocabListView.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/11/22.
//

import SwiftUI
import CoreData

typealias GroupedWordInfos = (chapter: Int, words: [Bible.WordInfo])

struct BuildVocabListView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    @State var bibleRanges: [BibleRange] = []
    @State var prevBibleRanges: [BibleRange] = []
    @State var textbookRanges: [TextbookRange] = []
    @State var prevTextbookRanges: [TextbookRange] = []
    @State var builtWords: [Bible.WordInfo] = []
    @State var isBuilding = false
    @State var showBuiltWords = false
    @State var showTextbookPicker = false
    
    var body: some View {
        List {
            if (bibleRanges.isEmpty && textbookRanges.isEmpty) {
                Text("It looks like you have not added any ranges yet. Tap the button below to get stared.")
                    .multilineTextAlignment(.center)
            }
            if textbookRanges.isEmpty && !bibleRanges.isEmpty {
                BibleRangesView()
            }
            if !textbookRanges.isEmpty && bibleRanges.isEmpty {
                TextbookRangesView()
            }
            Section {
                Menu(content: {
                    if textbookRanges.isEmpty {
                        Button(action: { withAnimation {
                            bibleRanges.append(.init())
                        } }, label: { Label("From Bible", systemImage: "book.closed") })
                    }
                    if bibleRanges.isEmpty {
                        Button(action: { showTextbookPicker = true }, label: { Label("From Textbook", systemImage: "book.closed") })
                    }
                }, label: {
                    HStack {
                        Text((bibleRanges.isEmpty && textbookRanges.isEmpty) ? "Add range" : "Add another range")
                        Spacer()
                    }
                })
            }
            if !bibleRanges.isEmpty || !textbookRanges.isEmpty {
                Section {
                    Button(action: {
                        onBuild()
                    }, label: {
                        Label(isBuilding ? "Building..." : "See words", systemImage: "list.bullet")
                    })
                    .disabled(bibleRanges.isEmpty && textbookRanges.isEmpty && API.main.builtTextbooks.value.isEmpty)
                    Button(action: {
                        onSave()
                    }, label: {
                        Label("Save list", systemImage: "checkmark.circle")
                    })
                    .disabled(builtWords.isEmpty)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { presentationMode.wrappedValue.dismiss() }, label: {
                    Text("Done")
                        .bold()
                })
            }
            ToolbarItemGroup(placement: .keyboard) {
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
        .sheet(isPresented: $showTextbookPicker) {
            TextbookSelectorView { textbook in
                add(textbookRange: .init(info: textbook, chapStart: 1, chapEnd: 1))
            }
        }
        .sheet(isPresented: $showBuiltWords) {
            NavigationStack {
                List {
                    Section {
                        Text("\(builtWords.count) words")
                    }
                    if !textbookRanges.isEmpty {
                        ForEach(groupedTextbookWords, id: \.chapter) { group in
                            Section {
                                ForEach(group.words) { word in
                                    VStack(alignment: .leading) {
                                        Text(word.lemma)
                                            .font(.bible24)
                                        Text(word.definition)
                                            .font(.subheadline)
                                    }
                                }
                            } header: {
                                Text("Chapter \(group.chapter)")
                            }
                        }
                    } else {
                        ForEach(builtWords) { word in
                            VStack(alignment: .leading) {
                                Text(word.lemma)
                                    .font(.bible24)
                                Text(word.definition)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .toolbar {
                    Button(action: { showBuiltWords = false }, label: { Text("Done").bold() })
                }
            }
        }
        .navigationDestination(for: Bible.WordInfo.self) { wordInfo in
            WordInstancesView(word: wordInfo.bound())
        }
        .interactiveDismissDisabled(true)
    }
    
    func onRemove(range: BibleRange) {
        guard let index = bibleRanges.firstIndex(where: { $0.id == range.id }) else { return }
        bibleRanges.remove(at: index)
    }
    
    func onRemove(range: TextbookRange) {
        guard let index = textbookRanges.firstIndex(where: { $0.id == range.id }) else { return }
        textbookRanges.remove(at: index)
    }
    
    func add(textbookRange: TextbookRange) {
        textbookRanges.append(textbookRange)
        fetchTextbookData()
    }
    
    func fetchTextbookData() {
        Task {
            await API.main.fetchGarretHebrew()
        }
    }
    
    var groupedTextbookWords: [GroupedWordInfos] {
        if textbookRanges.isEmpty {
            return []
        }
        let wordsByChapter: [String:[Bible.WordInfo]] = Dictionary(grouping: builtWords, by: { $0.chapter })
        return wordsByChapter
            .map { GroupedWordInfos(chapter: $0.key.toInt, words: $0.value) }
            .sorted { $0.chapter < $1.chapter }
    }
    
    func onSave() {
        // save list
        CoreDataManager.transaction(context: context) {
            let list = VocabWordList(context: context)
            list.id = UUID().uuidString
            list.title = "LIST"
            list.details = "DETAILS"
            list.lastStudied = Date()
            list.createdAt = Date()
            
            // save ranges
            for range in bibleRanges {
                let newRange = VocabWordRange(context: context)
                newRange.id = UUID().uuidString
                newRange.createdAt = Date()
                newRange.bookStart = range.bookStart.toInt16
                newRange.bookEnd = range.bookEnd.toInt16
                newRange.chapStart = range.chapStart.toInt16
                newRange.chapEnd = range.chapEnd.toInt16
                newRange.occurrences = range.occurrencesInt.toInt32
                newRange.sourceId = API.Source.Info.app.id
                list.addToRanges(newRange)
            }
            
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
            
            for range in textbookRanges {
                let newRange = VocabWordRange(context: context)
                newRange.id = UUID().uuidString
                newRange.createdAt = Date()
                newRange.bookStart = -1
                newRange.bookEnd = -1
                newRange.chapStart = range.chapStart.toInt16
                newRange.chapEnd = range.chapEnd.toInt16
                newRange.occurrences = -1
                newRange.sourceId = range.info.id
                list.addToRanges(newRange)
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func onBuild() {
        isBuilding = true
        if bibleRanges.isEmpty {
            if prevTextbookRanges == textbookRanges {
                showBuiltWords = true
                return
            }
            
            DispatchQueue.global().async {
                builtWords.removeAll()
                var words: Set<Bible.WordInfo> = []
                
                for range in textbookRanges {
                    VocabListBuilder.buildHebrewTextbookList(sourceId: range.info.id, chapterStart: range.chapStart, chapterEnd: range.chapEnd).forEach { words.insert($0) }
                }
                
                builtWords = Array(words)
                prevTextbookRanges = textbookRanges
                isBuilding = false
                showBuiltWords = true
            }
        } else {
            if prevBibleRanges == bibleRanges {
                showBuiltWords = true
                return
            }
            
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
}

extension BuildVocabListView {
    func BibleRangesView() -> some View {
        ForEach($bibleRanges) { range in
            BibleRangePickerView(range: range, onDelete: {
                withAnimation { onRemove(range: range.wrappedValue) }
            })
        }
    }
    
    func TextbookRangesView() -> some View {
        ForEach($textbookRanges) { range in
            TextbookRangePickerView(range: range, onDelete: {
                withAnimation { onRemove(range: range.wrappedValue) }
            })
        }
    }
}

struct BibleRangePickerView: View {
    @Binding var range: BibleRange
    var onDelete: () -> Void
    
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
                        print("published")
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
                        print("published")
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
        NavigationStack {
            BuildVocabListView()
        }
    }
}
