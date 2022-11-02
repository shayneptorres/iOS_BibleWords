//
//  BibleReadingView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/17/22.
//

import SwiftUI

struct BibleReadingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var passage: Passage = .init(book: .psalms, chapter: 1, verse: -1)
    @State var searchBook: Bible.Book = .psalms
    @State var searchChapter = 1
    
    @State var prevBook: Bible.Book = .psalms
    
    @State var searchVerse = -1
    @State var showPassageSelector = false
    @State var showWordDetail = false
    @State var showInstanceInfo = false
    @State var selectedWord: Bible.WordInstance = .init(dict: [:])
    @ObservedObject var viewModel = DataDependentViewModel()
    
    private let btnFontSize: CGFloat = 40
    
    var body: some View {
        VStack {
            if viewModel.isBuilding {
                DataLoadingRow()
            } else {
                ZStack {
                    ReadPassageView(passage: $passage, selectedWord: $selectedWord)
                    VStack {
                        Spacer()
                        if showWordDetail {
                            WordDetailsView(
                                wordInstance: $selectedWord,
                                onInfo: {
                                    showInstanceInfo = true
                                }, onClose: {
                                    showWordDetail = false
                                })
                            .frame(maxHeight: 400)
                        }
                        PassageNavigationBar()
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            if gesture.translation.width > 50 {
                                onPrev()
                            }
                            if gesture.translation.width < -50 {
                                onNext()
                            }
                        }
                )
            }
        }
        .sheet(isPresented: $showInstanceInfo) {
            NavigationStack {
                WordInfoDetailsView(word: selectedWord.wordInfo.bound())
            }
        }
        .onChange(of: selectedWord) { w in
            selectedWord = w
            showPassageSelector = false
            showWordDetail = true
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Done")
                        .bold()
                })
            }
            ToolbarItemGroup(placement: .principal) {
                Text("\(passage.book.title) \(passage.chapter)")
                    .font(.title2)
                    .bold()
            }
        }
    }
}

extension BibleReadingView {
    func PassageNavigationBar() -> some View {
        VStack {
            HStack {
                Button(action: {
                    onPrev()
                }, label: {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 24))
                        .padding(10)
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.accentColor))
                }).disabled(!canGoPrev)
                Spacer()
                Picker("", selection: $searchBook) {
                    ForEach(Bible.Book.allCases, id: \.rawValue) { book in
                        Text(book.title).tag(book)
                    }
                }
                .onChange(of: self.searchBook) { value in
                    setPassage()
                }
                Picker("", selection: $searchChapter) {
                    ForEach(1...chapCount, id: \.self) { chp in
                        Text("Ch \(chp)").tag(chp)
                    }
                }
                .onChange(of: self.searchChapter) { value in
                    setPassage()
                }
                Spacer()
                Button(action: {
                    onNext()
                }, label: {
                    Image(systemName: "arrow.forward")
                        .font(.system(size: 24))
                        .padding(10)
                        .foregroundColor(.white)
                        .background(Circle().fill(Color.accentColor))
                }).disabled(!canGoNext)
            }
            .padding(8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Design.defaultCornerRadius))
            .padding(.horizontal, 20)
            .padding(.bottom, 4)
        }
        .transition(.move(edge: .bottom))
    }
}

extension BibleReadingView {
    var chapCount: Int {
        Bible.main.references.values[passage.book.rawValue-1].count
    }
    
    var verseCount: Int {
        Bible.main.references.values[passage.book.rawValue-1][passage.chapter-1].count
    }
    
    var canGoPrev: Bool {
        return !(passage.book == .genesis && passage.chapter == 1)
    }
    
    var canGoNext: Bool {
        return !(passage.book == .revelation && passage.chapter == 22)
    }
}

extension BibleReadingView {
    func setPassage() {
        if searchChapter > searchBook.chapterCount {
            searchChapter = 1
        }
        passage = .init(book: searchBook, chapter: searchChapter, verse: searchVerse)
        showPassageSelector = false
    }
    
    func onPrev() {
        guard canGoPrev else { return }
        if passage.chapter > 1 {
            // if we are not showing the first chapter
            passage = .init(book: passage.book, chapter: passage.chapter-1, verse: -1)
        } else if passage.chapter == 1 {
            let prevChap = Bible.main.references.values[passage.book.rawValue-2].count
            let prevBook = Bible.Book(rawValue: passage.book.rawValue-1)
            passage = .init(book: prevBook!, chapter: prevChap, verse: -1)
        }
        self.searchBook = passage.book
        self.searchChapter = passage.chapter
        showWordDetail = false
    }
    
    func onNext() {
        guard canGoNext else { return }
        if passage.chapter < chapCount {
            let nextChap = passage.chapter + 1
            passage = .init(book: passage.book, chapter: nextChap, verse: -1)
        } else {
            let nextBook = Bible.Book(rawValue: passage.book.rawValue+1)
            passage = .init(book: nextBook!, chapter: 1, verse: -1)
        }
        self.searchBook = passage.book
        self.searchChapter = passage.chapter
        showWordDetail = false
    }
}

struct BibleReadingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BibleReadingView()
        }
    }
}
