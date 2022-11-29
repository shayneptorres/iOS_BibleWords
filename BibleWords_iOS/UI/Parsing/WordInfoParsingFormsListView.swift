//
//  WordInfoParsingFormsListView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/29/22.
//

import SwiftUI

struct WordInfoParsingFormsListView: View {
    struct ParsingGroup: Identifiable {
        var id: String = UUID().uuidString
        var groupName: String
        var instances: [Bible.WordInstance]
        
        var surfaceGroups: [ParsingGroup] {
            var surfaceDict: [String:[Bible.WordInstance]] = [:]
            for instance in instances {
                if surfaceDict[instance.textSurface] == nil {
                    surfaceDict[instance.textSurface] = [instance]
                } else {
                    surfaceDict[instance.textSurface]?.append(instance)
                }
            }
            
            var buildingGroups: [ParsingGroup] = []
            for (surface, instances) in surfaceDict {
                buildingGroups.append(.init(groupName: surface, instances: instances))
            }
            
            return buildingGroups
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    var wordInfo: Bible.WordInfo
    
    var groups: [ParsingGroup] {
        var buildingGroups: [ParsingGroup] = []
        
        let indicatives = ParsingGroup(groupName: "Indicatives", instances: wordInfo.instances.filter { $0.parsing.lowercased().contains("indicative") })
        let infinitives = ParsingGroup(groupName: "Infinitives", instances: wordInfo.instances.filter { $0.parsing.lowercased().contains("infinitive") })
        let subjunctives = ParsingGroup(groupName: "Subjunctives", instances: wordInfo.instances.filter { $0.parsing.lowercased().contains("subjunctive") })
        let imperatives = ParsingGroup(groupName: "Imperatives", instances: wordInfo.instances.filter { $0.parsing.lowercased().contains("imperative") })
        let participles = ParsingGroup(groupName: "Participles", instances: wordInfo.instances.filter { $0.parsing.lowercased().contains("participle") })
        buildingGroups = [indicatives, infinitives, subjunctives, imperatives, participles].filter { !$0.instances.isEmpty }
        
        return buildingGroups
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groups) { group in
                    Section {
                        ForEach(group.instances) { instance in
                            ParsingFormListRow(instance: instance)
                        }
                    } header: {
                        Text(group.groupName)
                    }
                }
            }
            .navigationBarTitle("Forms", displayMode: .inline)
            .toolbar {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Dismiss")
                        .bold()
                })
            }
        }
    }
}

//struct WordInfoParsingFormsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        WordInfoParsingFormsListView()
//    }
//}
