//
//  VocabWordIntervalStatsView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/23/22.
//

import SwiftUI
import Combine
import CoreData

struct VocabWordIntervalStatsView: View {
    
    enum StatDisplay {
        case byCount
        case byPercent
    }
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    @State var subscribers: [AnyCancellable] = []
    @State var isBuilding = false
    @State var display: StatDisplay = .byCount
    
    @State var intervalWords: [Int:[Bible.WordInfo]] = [:]
    var displayIntervals: [Int] {
        return Array(intervalWords.keys).sorted { $0 < $1 }
    }
    
    var body: some View {
        List {
            if isBuilding  {
                DataLoadingRow()
            } else {
                Section {
                    Picker("View as:", selection: $display) {
                        Label("Word Count", systemImage: "number").tag(StatDisplay.byCount)
                        Label("Percent", systemImage: "percent").tag(StatDisplay.byPercent)
                    }
                    HStack {
                        Label("Total Vocab words studying: ", systemImage: "sum")
                        Spacer()
                        Text("\(intervalWords.flatMap { $0.value }.count)")
                            .bold()
                            .foregroundColor(.accentColor)
                    }
                    HStack {
                        Label("Greek words studying: ", systemImage: "sum")
                        Spacer()
                        Text("\(intervalWords.flatMap { $0.value }.filter { $0.language == .greek }.count)")
                            .bold()
                            .foregroundColor(.accentColor)
                    }
                    HStack {
                        Label("Hebrew words studying: ", systemImage: "sum")
                        Spacer()
                        Text("\(intervalWords.flatMap { $0.value }.filter { $0.language == .hebrew && !$0.instances.isEmpty }.count)")
                            .bold()
                            .foregroundColor(.accentColor)
                    }
                    HStack {
                        Label("Custom words studying: ", systemImage: "sum")
                        Spacer()
                        Text("\(intervalWords.flatMap { $0.value }.filter { $0.instances.isEmpty }.count)")
                            .bold()
                            .foregroundColor(.accentColor)
                    }
                }
                Section {
                    VStack {
                        WordIntervalBarChartView(intervalWords: $intervalWords)
                    }
                    .frame(height: 300)
                }
                Section {
                    ForEach(displayIntervals, id: \.self) { intervalInt in
                        NavigationLink(destination: {
                            List(intervalWords[intervalInt] ?? []) { word in
                                NavigationLink(destination: {
                                    WordInfoDetailsView(word: word.bound())
                                }) {
                                    WordInfoRow(wordInfo: word.bound())
                                }
                            }
                            .toolbar {
                                ToolbarItemGroup(placement: .principal) {
                                    VStack {
                                        Text("\(VocabWord.defaultSRIntervals[intervalInt].toPrettyTime)")
                                            .font(.system(size: 17))
                                            .bold()
                                        Text("\((intervalWords[intervalInt] ?? []).count) words")
                                            .font(.system(size: 12))
                                    }
                                }
                            }
                            .navigationBarTitleDisplayMode(.inline)
                        }) {
                            HStack {
                                Text(VocabWord.defaultSRIntervals[intervalInt].toPrettyTime)
                                Spacer()
                                Text(statDisplay(for: intervalInt))
                                    .font(.subheadline)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                        }
                    }
                } header: {
                    Text("Vocab Word Stats")
                }
            }
        }
        .navigationBarTitle("Vocab Interval Stats")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard intervalWords.isEmpty else { return }
            getVocabStatData()
        }
    }
    
    func statDisplay(for index: Int) -> String {
        switch display {
        case .byCount:
            return "\(intervalWords[index]?.count ?? 0) words"
        case .byPercent:
            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            formatter.minimumIntegerDigits = 1
            formatter.maximumIntegerDigits = 2
            formatter.maximumFractionDigits = 1
            formatter.minimumFractionDigits = 1
            let val = Double(intervalWords[index]?.count ?? 0) / Double(intervalWords.flatMap { $0.value }.count)
            return formatter.string(for: val) ?? "0%"
        }
    }
    
    func getVocabStatData() {
        self.isBuilding = true
        let vocabFetchRequest = NSFetchRequest<VocabWord>(entityName: "VocabWord")
        var words: [VocabWord] = []
        do {
            words = try context.fetch(vocabFetchRequest)
        } catch let err {
            print(err)
        }
        words = words.filter { ($0.list?.count ?? 0) > 0 }
        
        API.main.coreDataReadyPublisher.sink { isReady in
            if isReady {
                DispatchQueue.global().async {
                    var intervalWordsDict: [Int:[Bible.WordInfo]] = [:]
                    for word in words {
                        if intervalWordsDict[word.currentInterval.toInt] == nil {
                            intervalWordsDict[word.currentInterval.toInt] = [word.wordInfo]
                        } else {
                            var currIntervalWords = intervalWordsDict[word.currentInterval.toInt] ?? []
                            currIntervalWords.append(word.wordInfo)
                            intervalWordsDict[word.currentInterval.toInt] = currIntervalWords
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.intervalWords = intervalWordsDict
                        self.isBuilding = false
                    }
                }
                
            }
        }.store(in: &self.subscribers)
    }
}

struct VocabWordIntervalStatsView_Previews: PreviewProvider {
    static var previews: some View {
        VocabWordIntervalStatsView()
    }
}
