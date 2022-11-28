//
//  StudyActivityView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/24/22.
//

import SwiftUI
import CoreData

struct StudyActivityView: View {
    enum Filter: Int, CaseIterable, Identifiable {
        case threeDay
        case week
        case month
        case year
        case all
        
        var id: Int { self.rawValue }
        
        var title: String {
            switch self {
            case .threeDay: return "3-day"
            case .week: return "Week"
            case .month: return "Month"
            case .year: return "Year"
            case .all: return "All"
            }
        }
    }
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode

    @State var filter = Filter.threeDay
    @State var allStudySessionEntries: [VocabStudySessionEntry] = []
    @State var activityGroups: [ActivityGroup] = []
    @State var filterAverage: Int = 0
    
    var body: some View {
        List {
            TodayActivitySection()
            FilterActivitySection()
            PastActivitySection()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Dismiss")
                        .bold()
                })
            }
        }
        .navigationTitle("Activity")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            sortData()
        }
    }
}

struct ActivityGroup: Identifiable {
    let id: String = UUID().uuidString
    let longName: String
    let shortName: String
    let entries: [VocabStudySessionEntry]
}

extension StudyActivityView {
    func sortData() {
        let studySessionFetchRequest = NSFetchRequest<VocabStudySessionEntry>(entityName: "VocabStudySessionEntry")
        var fetchedEntries: [VocabStudySessionEntry] = []
        do {
            fetchedEntries = try context.fetch(studySessionFetchRequest)
        } catch let err {
            print(err)
        }
        allStudySessionEntries = fetchedEntries
        
        var groups: [ActivityGroup] = []
        let now = Date()
        
        switch filter {
        case .threeDay:
            for i in 0...3 {
                let day = now.addingTimeInterval(-i.days.toDouble)
                var longName = ""
                let shortName = day.toPrettyShortDayMonthString
                if Calendar.current.isDateInToday(day) {
                    longName = "Today"
                } else if Calendar.current.isDateInYesterday(day) {
                    longName = "Yesterday"
                } else {
                    longName = day.toPrettyDayMonthString
                }
                groups.append(.init(
                    longName: longName,
                    shortName: shortName,
                    entries: fetchedEntries.filter { ($0.createdAt ?? Date()).isSameDay(as: day) }))
            }
            filterAverage = Array(groups.dropFirst()).reduce(0, { result, group in return result + group.entries.count }) / 3
        case .week:
            for i in 0...7 {
                let day = now.addingTimeInterval(-i.days.toDouble)
                var longName = ""
                let shortName = day.toPrettyShortDayMonthString
                if Calendar.current.isDateInToday(day) {
                    longName = "Today"
                } else if Calendar.current.isDateInYesterday(day) {
                    longName = "Yesterday"
                } else {
                    longName = day.toPrettyDayMonthString
                }
                groups.append(.init(
                    longName: longName,
                    shortName: shortName,
                    entries: fetchedEntries.filter { ($0.createdAt ?? Date()).isSameDay(as: day) }))
            }
            filterAverage = Array(groups.dropFirst()).reduce(0, { result, group in return result + group.entries.count }) / 7
        case .month:
            break
        case .year:
            break
        case .all:
            break
        }
        
        self.activityGroups = groups.reversed()
    }
}

extension StudyActivityView {
    @ViewBuilder
    func TodayActivitySection() -> some View {
        Section {
            HStack {
                Label("Words reviewed:", systemImage: "arrow.triangle.2.circlepath")
                Spacer()
                if let todayGroup = activityGroups.first(where: { $0.longName == "Today" }) {
                    Text("\(todayGroup.entries.filter { !$0.wasNewWord }.count)")
                        .bold()
                        .foregroundColor(.accentColor)
                }
            }
            HStack {
                Label("Words learned:", systemImage: "gift")
                Spacer()
                if let todayGroup = activityGroups.first(where: { $0.longName == "Today" }) {
                    Text("\(todayGroup.entries.filter { $0.wasNewWord }.count)")
                        .bold()
                        .foregroundColor(.accentColor)
                }
            }
        } header: {
            Text("Today's Activity")
        }
    }
    
    @ViewBuilder
    func FilterActivitySection() -> some View {
        Section {
            Picker(selection: $filter, content: {
                ForEach(Filter.allCases) { filterOption in
                    Text(filterOption.title).tag(filterOption)
                }
            }, label: {
                Label("View Activity by:", systemImage: "eye")
            })
            .onChange(of: filter) { val in
                sortData()
            }
            VocabActivityLineChart(groups: $activityGroups)
                .frame(height: 300)
            ForEach(activityGroups.reversed()) { group in
                HStack {
                    Text(group.longName)
                    Spacer()
                    Text("\(group.entries.count) words studied")
                        .font(.caption)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                }
            }
        } header: {
            Text("\(filter.title) Summary")
        }
    }
    
    @ViewBuilder
    func PastActivitySection() -> some View {
        Section {
            HStack {
                Label("Total words reviewed:", systemImage: "clock.arrow.2.circlepath")
                Spacer()
                Text("\(allStudySessionEntries.count)")
                    .bold()
                    .foregroundColor(.accentColor)
            }
            HStack {
                Label("Past \(filter.title) Average:", systemImage: "calendar")
                Spacer()
                Text("\(filterAverage)")
                    .bold()
                    .foregroundColor(.accentColor)
            }
            NavigationLink(destination: {
                VocabWordIntervalStatsView()
            }, label: {
                Label("Vocab Word Intervals", systemImage: "chart.bar.fill")
            })
        } header: {
            Text("Past Activity")
        }
    }
}

struct StudyActivityView_Previews: PreviewProvider {
    static var previews: some View {
        StudyActivityView()
    }
}
