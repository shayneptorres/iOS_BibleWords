//
//  ParsingFormsListView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/29/22.
//

import SwiftUI

struct ParsingFormsListView: View {
    struct ParsingGroup: Identifiable {
        var id: String = UUID().uuidString
        var name: String
        var groups: [Bible.ParsingSurfaceGroup]
    }
    
    var wordInfo: Bible.WordInfo
    var modalDismiss: (() -> Void)?
    
    var parsingGroups: [ParsingGroup] {
        switch wordInfo.language {
        case .greek:
            if wordInfo.instances.first?.parsing.lowercased().contains("verb") == true {
                return moodGroups
            } else {
                return caseGroups
            }
        case .hebrew, .aramaic:
            if wordInfo.instances.first?.parsing.lowercased().contains("verb") == true {
                return hebVerbGroups
            } else {
                return hebNounGroups
            }
        default:
            return []
        }
    }
    
    var moodGroups: [ParsingGroup] {
        var buildingGroups: [ParsingGroup] = []
        
        for mood in Parsing.Greek.Mood.allCases {
            let group = ParsingGroup(name: mood.rawValue.capitalized, groups: wordInfo.parsingGroups.filter { $0.parsing.lowercased().contains(mood.rawValue) })
            if !group.groups.isEmpty {
                buildingGroups.append(group)
            }
        }
        
        return buildingGroups
    }
    
    var caseGroups: [ParsingGroup] {
        var buildingGroups: [ParsingGroup] = []
        
        for nounCase in Parsing.Greek.Case.allCases {
            let group = ParsingGroup(name: nounCase.rawValue.capitalized, groups: wordInfo.parsingGroups.filter { $0.parsing.lowercased().contains(nounCase.rawValue) })
            if !group.groups.isEmpty {
                buildingGroups.append(group)
            }
        }
        
        return buildingGroups
    }
    
    var hebVerbGroups: [ParsingGroup] {
        var buildingGroups: [ParsingGroup] = []
        
        for stem in Parsing.Hebrew.Stem.allCases {
            let group = ParsingGroup(name: stem.rawValue.capitalized, groups: wordInfo.parsingGroups.filter { $0.parsing.lowercased().contains(stem.rawValue) })
            if !group.groups.isEmpty {
                buildingGroups.append(group)
            }
        }
        
        return buildingGroups
    }
    
    var hebNounGroups: [ParsingGroup] {
        return [ParsingGroup(name: "Nouns", groups: wordInfo.parsingGroups)]
    }
    
    var body: some View {
        List {
            ParsingFormsPieChart(paringGroups: .init(get: { parsingGroups }, set: { _ in }))
                .frame(height: 300)
            ForEach(parsingGroups) { group in
                ParsingFormListSection(group: group)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(wordInfo.lemma)
                    .font(wordInfo.language.meduimBibleFont)
            }
            ToolbarItem(placement: .primaryAction) {
                if modalDismiss != nil {
                    Button(action: {
                        modalDismiss?()
                    }, label: {
                        Text("Dismiss")
                            .bold()
                    })
                }
            }
        }
    }
    
    struct ParsingFormListSection: View {
        let group: ParsingGroup
        @State var visible = true
        
        var body: some View {
            Section {
                if visible {
                    ForEach(group.groups.sorted(by: { $0.parsing < $1.parsing })) { g in
                        ParsingSurfaceGroupListRow(group: g)
                    }
                }
            } header: {
                HStack {
                    Text(group.name)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            visible.toggle()
                        }
                    }, label: {
                        Image(systemName: "chevron.up")
                            .rotationEffect(visible ? Angle(degrees: 0) : Angle(degrees: 180))
                    })
                }
            }
        }
    }
}



//struct ParsingFormsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ParsingFormsListView()
//    }
//}
