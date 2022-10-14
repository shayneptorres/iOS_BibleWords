//
//  BuildVocabListView.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/11/22.
//

import SwiftUI

struct BuildVocabListView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    @State var bibleRanges: [BibleRange] = []
    @State var prevBibleRanges: [BibleRange] = []
    @State var builtWords: [Bible.WordInfo] = []
    @State var isBuilding = false
    @State var showBuiltWords = false
    
    var body: some View {
        List {
            if bibleRanges.isEmpty {
                Text("It looks like you have not added any ranges yet. Tap the button below to get stared.")
                    .multilineTextAlignment(.center)
            }
            BibleRangesView()
            Section {
                Button(action: {
                    withAnimation {
                        bibleRanges.append(.init())
                    }
                }, label: {
                    Text(bibleRanges.isEmpty ? "Add range" : "Add another range")
                })
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { presentationMode.wrappedValue.dismiss() }, label: {
                    Text("Done")
                        .bold()
                })
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: onBuild, label: {
                    Image(systemName: "list.bullet")
                    Text(isBuilding ? "Building..." : "See words")
                })
                .disabled(bibleRanges.isEmpty)
                Button(action: onSave, label: {
                    Image(systemName: "checkmark.circle")
                    Text("Save list")
                })
                .disabled(bibleRanges.isEmpty)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
        .navigationTitle("Build Vocab List")
        .navigationDestination(isPresented: $showBuiltWords) {
            List {
                Section {
                    Text("\(builtWords.count) words")
                }
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
        .navigationDestination(for: Bible.WordInfo.self) { wordInfo in
            WordInstancesView(word: wordInfo.bound())
        }
        .interactiveDismissDisabled(true)
    }
    
    func onRemove(range: BibleRange) {
        guard let index = bibleRanges.firstIndex(where: { $0.id == range.id }) else { return }
        withAnimation {
            bibleRanges.remove(at: index)
        }
    }
    
    func onSave() {
        // save list
        CoreDataManager.transaction(context: context) {
            let list = WordList(context: context)
            list.id = UUID().uuidString
            list.title = "LIST"
            list.details = "DETAILS"
            list.createdAt = Date()
            
            // save ranges
            for range in bibleRanges {
                let newRange = WordRange(context: context)
                newRange.id = UUID().uuidString
                newRange.createdAt = Date()
                newRange.bookStart = range.bookStart.toInt16
                newRange.bookEnd = range.bookEnd.toInt16
                newRange.chapStart = range.chapStart.toInt16
                newRange.chapEnd = range.chapEnd.toInt16
                newRange.occurrences = range.occurrencesInt.toInt32
                list.addToRanges(newRange)
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func onBuild() {
        isBuilding = true
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

extension BuildVocabListView {
    func BibleRangesView() -> some View {
        ForEach($bibleRanges) { range in
            BibleRangePickerView(range: range, onDelete: {
                onRemove(range: range.wrappedValue)
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
                    Picker("", selection: $range.chapStart) {
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
