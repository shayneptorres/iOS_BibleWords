//
//  BibleReadingView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/17/22.
//

import SwiftUI

struct BibleReadingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var passage: Passage = .init(book: .genesis, chapter: 1, verse: -1)
    @State var searchBook: Bible.Book = .genesis
    @State var searchChapter = 1
    @State var searchVerse = -1
    @State var showPassageSelector = false
    @ObservedObject var viewModel = DataDependentViewModel()
    
    private let btnFontSize: CGFloat = 40
    
    var body: some View {
        VStack {
            if viewModel.isBuilding {
                DataLoadingRow()
            } else {
                ZStack {
                    ReadPassageView(passage: $passage)
                        
                    VStack {
                        Spacer()
                        HStack {
                            Button(action: {
                                onPrev()
                            }, label: {
                                Image(systemName: "arrow.left.circle.fill")
                                    .font(.system(size: btnFontSize))
                            }).disabled(!canGoPrev)
                            Spacer()
                            Button(action: {
                                onNext()
                            }, label: {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: btnFontSize))
                            }).disabled(!canGoNext)
                        }
                        .padding(8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 4)
                        
                    }
                    if showPassageSelector {
                        VStack {
                            VStack {
                                HStack {
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
                                            .cornerRadius(8)
                                    })
                                }
                            }
                            .frame(maxHeight: 30)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                            .cornerRadius(10)
                            .padding()
                            .shadow(radius: 2)
                            Spacer()
                        }
                        .transition(.move(edge: .top))
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded { gesture in
                            if gesture.translation.width > 0 {
                                onPrev()
                            } else {
                                onNext()
                            }
                        }
                )
            }
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
    var chapCount: Int {
        Bible.main.references.values[searchBook.rawValue-1].count
    }
    
    var verseCount: Int {
        Bible.main.references.values[searchBook.rawValue-1][searchChapter-1].count
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
            let prevChap = Bible.main.references.values[passage.book.rawValue-1].count
            let prevBook = Bible.Book(rawValue: passage.book.rawValue-1)
            passage = .init(book: prevBook!, chapter: prevChap, verse: -1)
        }
    }
    
    func onNext() {
        guard canGoNext else { return }
        if passage.chapter < chapCount {
            // get nextbook
            let nextChap = passage.chapter + 1
            passage = .init(book: passage.book, chapter: nextChap, verse: -1)
        } else {
            // get nextbook
            let nextChap = 1
            let nextBook = Bible.Book(rawValue: passage.book.rawValue+1)
            passage = .init(book: nextBook!, chapter: nextChap, verse: -1)
        }
    }
}

struct BibleReadingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BibleReadingView()
        }
    }
}
