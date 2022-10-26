//
//  TodayStatsWidget.swift
//  TodayStatsWidget
//
//  Created by Shayne Torres on 10/21/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    let dummy = TodayStatsEntry(date: Date(), reviewedCount: 254, parsedCount: 25, newCount: 75, dueCount: 45)
    func placeholder(in context: Context) -> TodayStatsEntry {
        return dummy
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayStatsEntry) -> ()) {
        var entries: [TodayStatsEntry] = AppGroupManager.getStats().map { $0.toEntry }
        entries = entries.filter { $0.date < Date() }.sorted { $0.date > $1.date }
        let entry = entries.first ?? dummy
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries: [TodayStatsEntry] = AppGroupManager.getStats().map { $0.toEntry }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct TodayStatsWidgetEntryView : View {
    var entry: TodayStatsEntry

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color.widgetBGColor)
            VStack(alignment: .center) {
                Text("Today's Stats")
                    .font(.title3)
                    .bold()
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                HStack {
                    VStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.headline)
                            .bold()
                        Text("\(entry.reviewedCount)")
                    }
                    .frame(maxWidth: .infinity)
                    VStack {
                        Image(systemName: "gift")
                            .font(.headline)
                            .bold()
                        Text("\(entry.newCount)")
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 16)
                .padding(.horizontal)
                HStack {
                    VStack {
                        Image(systemName: "rectangle.and.hand.point.up.left.filled")
                            .font(.headline)
                            .bold()
                        Text("\(entry.parsedCount)")
                    }
                    .frame(maxWidth: .infinity)
                    VStack {
                        Image(systemName: "clock.badge.exclamationmark")
                            .font(.headline)
                            .bold()
                        Text("\(entry.dueCount)")
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                Spacer()
            }
            .foregroundColor(Color.widgetTextColor)
        }
    }
}

@main
struct TodayStatsWidget: Widget {
    let kind: String = "TodayStatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TodayStatsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct TodayStatsWidget_Previews: PreviewProvider {
    static var previews: some View {
        TodayStatsWidgetEntryView(entry: TodayStatsEntry(date: Date(), reviewedCount: 235, parsedCount: 25, newCount: 75, dueCount: 45))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
