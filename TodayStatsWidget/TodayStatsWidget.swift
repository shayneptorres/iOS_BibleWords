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
                    .foregroundColor(Color.widgetTextColor)
                HStack {
                    VStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(Color.widgetTextColor)
                            .font(.headline)
                            .bold()
                        Text("\(entry.reviewedCount)")
                    }
                    .frame(maxWidth: .infinity)
                    VStack {
                        Image(systemName: "gift")
                            .foregroundColor(Color.widgetTextColor)
                            .font(.headline)
                            .bold()
                        Text("\(entry.newCount)")
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 8)
                .padding(.horizontal)
                HStack {
                    VStack {
                        Image(systemName: "rectangle.and.hand.point.up.left.filled")
                            .foregroundColor(Color.widgetTextColor)
                            .font(.headline)
                            .bold()
                        Text("\(entry.parsedCount)")
                    }
                    .frame(maxWidth: .infinity)
                    VStack {
                        Image(systemName: "clock.badge.exclamationmark")
                            .foregroundColor(Color.widgetTextColor)
                            .font(.headline)
                            .bold()
                        Text("\(entry.dueCount)")
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                Spacer()
            }
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
        .configurationDisplayName("Today's Stats")
        .description("Provides a quick glance at your current App stats (reviewed words, new words, parsed words, and due words)")
        .supportedFamilies([.systemSmall])
    }
}

struct TodayStatsWidget_Previews: PreviewProvider {
    static var previews: some View {
        TodayStatsWidgetEntryView(entry: TodayStatsEntry(date: Date(), reviewedCount: 235, parsedCount: 25, newCount: 75, dueCount: 45))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
