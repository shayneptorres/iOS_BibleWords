//
//  ParsingFormDetailView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/29/22.
//

import SwiftUI

struct ParsingFormDetailView: View {
    @Environment(\.managedObjectContext) var context
    let parsingGroup: Bible.ParsingSurfaceGroup
    
    var body: some View {
        List {
            WordOccurrenceBarChartView(occurrences: .constant(parsingGroup.instances))
                .frame(height: 300)                
            if let instance = parsingGroup.instances.first {
                ParsingFormInfoHeader(instance: instance)
            }
            ForEach(parsingGroup.instances) { instance in
                WordInstancePassageListRow(instance: instance)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let instance = parsingGroup.instances.first {
                    Text(instance.textSurface.lowercased())
                        .font(instance.language.meduimBibleFont)
                } else {
                    Text("")
                }
            }
        }
    }
}

//struct ParsingFormDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        ParsingFormDetailView()
//    }
//}
