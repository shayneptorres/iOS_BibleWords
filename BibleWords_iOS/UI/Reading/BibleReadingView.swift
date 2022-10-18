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
                WordInstancesView(word: selectedWord.wordInfo.bound())
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
                Button(action: {
                    withAnimation {
                        showPassageSelector.toggle()
                    }
                }, label: {
                    Text("\(passage.book.title) \(passage.chapter)")
                })
                .disabled(viewModel.isBuilding)
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
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.system(size: btnFontSize))
                }).disabled(!canGoPrev)
                Spacer()
                Picker("", selection: $searchBook) {
                    ForEach(Bible.Book.allCases, id: \.rawValue) { book in
                        Text(book.title).tag(book)
                    }
                }
                Picker("", selection: $searchChapter) {
                    ForEach(1...chapCount, id: \.self) { chp in
                        Text("Ch \(chp)").tag(chp)
                    }
                }
                Button(action: {
                    setPassage()
                }, label: {
                    Image(systemName: "text.magnifyingglass")
                        .font(.system(size: 24))
                        .padding(8)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(Design.defaultCornerRadius)
                })
                Spacer()
                Button(action: {
                    onNext()
                }, label: {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: btnFontSize))
                }).disabled(!canGoNext)
            }
            .padding(8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Design.defaultCornerRadius))
            .padding(.horizontal, 20)
            .padding(.bottom, 4)
        }
        .transition(.move(edge: .bottom))
    }
    
//    func WordDetailView() -> some View {
//        VStack {
//            Spacer()
//            VStack {
//                Text(selectedWord.rawSurface)
//                    .font(.bible32)
//                    .padding(.bottom,4)
//                    .onTapGesture {
//                        let pasteboard = UIPasteboard.general
//                        pasteboard.string = selectedWord.rawSurface
//                    }
//                Text(selectedWord.surface)
//                    .font(.bible32)
//                    .padding(.bottom,4)
//                    .onTapGesture {
//                        let pasteboard = UIPasteboard.general
//                        pasteboard.string = selectedWord.surface
//                    }
//                Text(selectedWord.wordInfo.lemma)
//                    .font(.bible32)
//                    .padding(.bottom,4)
//                    .onTapGesture {
//                        let pasteboard = UIPasteboard.general
//                        pasteboard.string = selectedWord.wordInfo.lemma
//                    }
//                Text(selectedWord.wordInfo.definition)
//                    .padding(.bottom,4)
//                Text(selectedWord.parsing)
//                    .padding(.bottom,4)
//                Button(action: {
//                    showWordDetail = false
//                }, label: {
//                    Image(systemName: "xmark.circle")
//                        .font(.system(size: 24))
//                })
//            }
//            .padding(8)
//            .frame(maxWidth: .infinity, maxHeight: 350)
//            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Design.defaultCornerRadius))
//            .padding(.horizontal, 20)
//            .padding(.bottom, 4)
//            .transition(.move(edge: .bottom))
//        }
//    }
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
        showWordDetail = false
    }
    
    func onNext() {
        guard canGoNext else { return }
        if passage.chapter < chapCount {
            let nextChap = passage.chapter + 1
            passage = .init(book: passage.book, chapter: nextChap, verse: -1)
        } else {
            let nextChap = 1
            let nextBook = Bible.Book(rawValue: passage.book.rawValue+1)
            passage = .init(book: nextBook!, chapter: 1, verse: -1)
        }
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
