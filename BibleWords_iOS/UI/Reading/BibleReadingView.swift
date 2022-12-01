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
    @ObservedObject var viewModel = DataDependentViewModel()
    @State var searchBook: Bible.Book = .psalms
    @State var searchChapter = 1
    @State var prevBook: Bible.Book = .psalms
    @State var searchVerse = -1
    @State var showPassageSelector = false
    @State var showWordDetail = false
    @State var showInstanceInfo = false
    @State var showViewSettingsView = false
    @State var selectedWord: Bible.WordInstance = .init(dict: [:])
    @State var fontSize: CGFloat = 45
    @State var viewColor: Color = .appBackground
    
    let bookGridLayout: [GridItem] = [.init(.flexible()), .init(.flexible()), .init(.flexible())]
    let verseGridLayout: [GridItem] = [.init(.flexible()), .init(.flexible()), .init(.flexible()), .init(.flexible()), .init(.flexible())]
    
    private let btnFontSize: CGFloat = 40
    
    var body: some View {
        VStack {
            if viewModel.isBuilding {
                DataLoadingRow()
            } else {
                ZStack {
                    ReadPassageView(passage: $passage, selectedWord: $selectedWord, fontSize: $fontSize, buffer: 75)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                showPassageSelector = true
                            }, label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.accentColor)
                                        .frame(width: 60, height: 60)
                                    Image(systemName: "books.vertical")
                                        .font(.title)
                                        .foregroundColor(.white)
                                }
                            })
                            .padding([.trailing, .bottom])
                        }
                    }
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
                    }
                    if showPassageSelector {
                        ZStack {
                            Color
                                .black
                                .opacity(0.8)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    showPassageSelector = false
                                }
                            VStack {
                                Spacer()
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            showPassageSelector = false
                                        }, label: {
                                            Image(systemName: "xmark.circle")
                                                .font(.title3)
                                                .foregroundColor(.accentColor)
                                        })
                                    }
                                    HStack {
                                        VStack {
                                            Text("Select Book")
                                            ScrollView {
                                                LazyVGrid(columns: bookGridLayout, spacing: 4) {
                                                    ForEach(Bible.Book.allCases, id: \.rawValue) { book in
                                                        VStack {
                                                            Text(book.shortTitle)
                                                                .font(.footnote)
                                                                .frame(maxWidth: .infinity, minHeight: 30)
                                                                .padding(12)
                                                                .background(searchBook == book ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                                                .cornerRadius(Design.defaultCornerRadius)
                                                        }
                                                        .onTapGesture {
                                                            searchBook = book
                                                        }
                                                    }
                                                }
                                                .onChange(of: self.searchBook) { value in
                                                    setPassage()
                                                }
                                            }
                                        }
                                        Divider()
                                        VStack {
                                            Text("Select Chapter")
                                            ScrollView {
                                                LazyVGrid(columns: bookGridLayout, spacing: 4) {
                                                    ForEach(1...chapCount, id: \.self) { chp in
                                                        Text("\(chp)")
                                                            .font(.subheadline)
                                                            .frame(maxWidth: .infinity, minHeight: 30)
                                                            .padding(12)
                                                            .background(searchChapter == chp ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                                            .cornerRadius(Design.defaultCornerRadius)
                                                            .onTapGesture {
                                                                searchChapter = chp
                                                            }
                                                    }
                                                }
                                                .onChange(of: self.searchChapter) { value in
                                                    setPassage()
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity, maxHeight: 400)
                                .padding(.horizontal, 4)
                                .background(Color(uiColor: .secondarySystemBackground))
                                .foregroundColor(Color(uiColor: .label))
                                .cornerRadius(Design.defaultCornerRadius)
                            }
                        }
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
            NavigationView {
                WordInfoDetailsView(word: selectedWord.wordInfo.bound(), isPresentedModally: true)
            }
        }
        .sheet(isPresented: $showViewSettingsView) {
            NavigationView {
                List {
                    NavigationLink(destination: {
                        List {
                            Stepper(value: $fontSize, label: {
                                Label("Font Size", systemImage: "textformat.size")
                            })
                            Section {
                                ReadPassageView(
                                    passage: .constant(.init(book: .genesis, chapter: 1, verse: 1)),
                                    selectedWord: .constant(.init(dict: [:])),
                                    fontSize: $fontSize)
                                ReadPassageView(
                                    passage: .constant(.init(book: .john, chapter: 1, verse: 1)),
                                    selectedWord: .constant(.init(dict: [:])),
                                    fontSize: $fontSize)
                            }
                        }
                    }, label: {
                        Label("Font size", systemImage: "textformat.size")
                    })
                }
                .navigationTitle("View Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button("Dismiss", action: {
                            showViewSettingsView = false
                        })
                    }
                }
            }
        }
        .onChange(of: selectedWord) { w in
            selectedWord = w
            showPassageSelector = false
            showWordDetail = true
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Dismiss")
                        .bold()
                })
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    showViewSettingsView = true
                }, label: {
                    Image(systemName: "gearshape.fill")
                })
            }
            ToolbarItemGroup(placement: .principal) {
                Button(action: {
                    showPassageSelector.toggle()
                }, label: {
                    Text("\(passage.book.title) \(passage.chapter)")
                        .font(.title3)
                        .bold()
                })
            }
        }
        .onAppear {
            searchBook = passage.book
            searchChapter = passage.chapter
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
                        Text(book.shortTitle).tag(book)
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
        NavigationView {
            BibleReadingView()
        }
    }
}
