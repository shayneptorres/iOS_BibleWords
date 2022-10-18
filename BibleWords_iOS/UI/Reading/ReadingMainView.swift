////
////  ReadingMainView.swift
////  BibleWords_iOS
////
////  Created by Shayne Torres on 10/17/22.
////
//
//import SwiftUI
//
//struct ReadingMainView: View {
//    @ObservedObject var viewModel = DataDependentViewModel()
//    @State var showMessage = true
//    
//    var body: some View {
//        List {
//            Section {
//                Text("This is the reading section of the BibleWords app. Here is where you can apply your knowledge and skills gained from studing vocab and practicing parsing. You can work through different books in the bible to see how well you can read, understand, and interpret them")
//                    .font(.body.weight(.semibold))
//                    .multilineTextAlignment(.center)
//            }
//            if viewModel.isBuilding {
//                DataLoadingRow()
//            } else {
////                Section {
////                    
////                }
////                Section {
////                    ForEach(Bible.Book.allCases, id: \.rawValue) { book in
////                        NavigationLink(destination: ReadingChapterSelectView(book: book)) {
////                            Text(book.title)
////                        }
////                    }
////                } header: {
////                    Text("Bible Books")
////                }
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationTitle("Reading")
//    }
//}
//
//struct ReadingChapterSelectView: View {
//    var book: Bible.Book
//    
//    var body: some View {
//        List {
//            ForEach(Array(1...book.chapterCount), id: \.self) { i in
//                NavigationLink(destination: ReadingVerseSelectView(book: book, chapter: i)) {
//                    Text("\(book.title) \(i)")
//                }
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationTitle(book.title)
//    }
//}
//
//struct ReadingVerseSelectView: View {
//    var book: Bible.Book
//    var chapter: Int
//    
//    var body: some View {
//        List {
//            ForEach(Array(1...Bible.main.references.values[book.rawValue-1][chapter-1].count), id: \.self) { i in
//                NavigationLink(destination: ReadPassageView(book: book, chapter: chapter, verse: i)) {
//                    Text("\(book.title) \(chapter):\(i)")
//                }
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationTitle("\(book.title) \(chapter)")
//    }
//}
//
//struct ReadingMainView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReadingMainView()
//    }
//}
