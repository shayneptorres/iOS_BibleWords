//
//  ReadingMainView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/17/22.
//

import SwiftUI

struct BibleReadingMainView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PassageBookmark.createdAt, ascending: false)]
    ) var bookmarks: FetchedResults<PassageBookmark>
    
    @State var showBibleReader = false
    @State var passage: Passage = .init(book: .psalms, chapter: 1, verse: -1)
    
    var ntBookmarks: [PassageBookmark] {
        bookmarks.filter { $0.bookInt >= 40 }
    }
    
    var otBookmarks: [PassageBookmark] {
        bookmarks.filter { $0.bookInt < 40 }
    }
    
    var body: some View {
        List {
            Button(action: {
                passage = .init(book: .psalms, chapter: 1, verse: -1)
                showBibleReader = true
            }, label: {
                Label("Bible", systemImage: "books.vertical")
            })
            Section {
                ForEach(otBookmarks) { bookmark in
                    Button(action: {
                        passage = bookmark.passage
                        showBibleReader = true
                    }, label: {
                        Text("\(bookmark.passage.book.title) \(bookmark.passage.chapter)")
                    })
                }
            } header: {
                Text("OT Bookmarks")
            }
            Section {
                ForEach(ntBookmarks) { bookmark in
                    Button(action: {
                        passage = bookmark.passage
                        showBibleReader = true
                    }, label: {
                        Text("\(bookmark.passage.book.title) \(bookmark.passage.chapter)")
                    })
                }
            } header: {
                Text("NT Bookmarks")
            }
        }
        .fullScreenCover(isPresented: $showBibleReader) {
            NavigationView {
                BibleReadingView(passage: $passage)
            }
        }
    }
}
