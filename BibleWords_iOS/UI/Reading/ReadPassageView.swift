//
//  ReadPassageView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/17/22.
//

import SwiftUI

struct Passage: Equatable {
    var book: Bible.Book = .genesis
    var chapter: Int = 1
    var verse: Int = 1
    var words: [Bible.WordInstance]
    
    static func == (lhs: Passage, rhs: Passage) -> Bool {
        return (lhs.book) == (rhs.book) &&
        (lhs.chapter) == (rhs.chapter) &&
        (lhs.verse) == (rhs.verse)
    }
    
    init(book: Bible.Book = .genesis, chapter: Int = 1, verse: Int = 1) {
        self.book = book
        self.chapter = chapter
        self.verse = verse
        self.words = Bible.main.references.verses(book: book.rawValue, chapter: chapter, verse: verse)
    }
}

struct ReadPassageView: View {
    let viewModel = DataDependentViewModel()
    @Binding var passage: Passage
    
    var body: some View {
        ScrollView {
            ScrollViewReader { reader in
                if passage.book.rawValue < 40 {
                    HebrewPassageTextView(words: $passage.words).id(1)
                        .padding(8)
                        .onChange(of: passage) { i in
                            reader.scrollTo(1, anchor: .top)
                        }
                } else {
                    GreekPassageTextView(words: $passage.words).id(2)
                        .padding(8)
                        .onChange(of: passage) { i in
                            reader.scrollTo(2, anchor: .top)
                        }
                }
            }
        }
    }
}

extension ReadPassageView {
    func passageText() -> String {
        return ""
    }
    
    var passageWordInstances: [Bible.WordInstance] {
        return Bible.main.references.verses(book: passage.book.rawValue, chapter: passage.chapter, verse: passage.verse)
    }
}

struct ReadPassageView_Previews: PreviewProvider {
    static var previews: some View {
        ReadPassageView(passage: .constant(.init()))
    }
}

struct GreekPassageTextView: View {
    @Binding var words: [Bible.WordInstance]
    @State var selectedWord: Bible.WordInstance?
    @State private var size: CGSize = .zero
    let buffer: CGFloat = 50
    
    var body : some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return VStack {
            GeometryReader { g in
                ZStack(alignment: .topLeading) {
                    ForEach(0..<self.words.count, id: \.self) { i in
                        Text("" + self.words[i].rawSurface + " ")
                            .font(.bible24)
                            .padding([.horizontal, .vertical], 4)
                            .onTapGesture {
                                selectedWord = self.words[i]
                            }
                            .foregroundColor(selectedWord == self.words[i] ? .accentColor : Color(uiColor: .label))
                            .alignmentGuide(.leading, computeValue: { d in
                                if (abs(width - d.width) > g.size.width)
                                {
                                    width = 0
                                    height -= d.height
                                }
                                let result = width
                                if i < self.words.count-1 {
                                    width -= d.width
                                } else {
                                    width = 0 //last item
                                }
                                return result
                            })
                            .alignmentGuide(.top, computeValue: {d in
                                let result = height
                                if i >= self.words.count-1 {
                                    height = 0 // last item
                                }
                                return result
                            })
                    }
                }
                .readVerticalFlowSize(to: $size)
            }
            .frame(height: (size.height + buffer) > 0 ? (size.height + buffer) : nil)
        }
    }
}

struct HebrewPassageTextView: View {
    @Binding var words: [Bible.WordInstance]
    @State var selectedWord: Bible.WordInstance?
    @State private var size: CGSize = .zero
    let buffer: CGFloat = 50
    
    var body : some View {
        var height = CGFloat.zero
        var rowWidths: [CGFloat] = [0]
        
        return VStack {
            GeometryReader { g in
                ZStack(alignment: .topTrailing) {
                    Color.clear.opacity(0.0001)
                    ForEach(0..<self.words.count, id: \.self) { i in
                        Text(self.words[i].rawSurface + " ")
                            .font(self.words[i].id == "verse-num" ? .system(size: 12) : .bible40)
                            .padding([.horizontal, .vertical], 4)
                            .onTapGesture {
                                selectedWord = self.words[i]
                            }
                            .foregroundColor(selectedWord == self.words[i] ? .accentColor : Color(uiColor: .label))
                            .alignmentGuide(.trailing, computeValue: { d in
                                if (abs(rowWidths[rowWidths.count - 1] - d.width) > g.size.width)
                                {
                                    rowWidths[rowWidths.count - 1] = 0
                                    height -= d.height
                                    rowWidths.append(0)
                                }
                                
                                let result = d[.trailing] - rowWidths[rowWidths.count - 1]
                                if i < self.words.count-1 {
                                    rowWidths[rowWidths.count - 1] -= d.width
                                } else {
                                    rowWidths[rowWidths.count - 1] = 0 //last item
                                }
                                
                                return result
                            })
                            .alignmentGuide(.top, computeValue: {d in
                                let result = height
                                if i >= self.words.count-1 {
                                    height = 0 // last item
                                }
                                return result
                            })
                    }
                }
                .readVerticalFlowSize(to: $size)
            }
            .frame(height: (size.height + buffer) > 0 ? (size.height + buffer) : nil)
        }
    }
}


private extension View {
    
    func readVerticalFlowSize(to size: Binding<CGSize>) -> some View {
        background(GeometryReader { proxy in
            Color.clear.preference(
                key: VerticalFlowSizePreferenceKey.self,
                value: proxy.size
            )
        })
        .onPreferenceChange(VerticalFlowSizePreferenceKey.self) {
            size.wrappedValue = $0
        }
    }
    
}

private struct VerticalFlowSizePreferenceKey: PreferenceKey {
    
    static let defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        let next = nextValue()
        if next != .zero {
            value = next
        }
    }
    
}
