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
    @Environment(\.widgetFamily) private var family
    var entry: TodayStatsEntry

    var body: some View {
        switch family {
        case .systemSmall:
//            StatsDueReviewedSmallView(entry: entry)
            StatsDueSmallView(entry: entry)
        case .systemMedium:
            StatsMediumWidgetView(entry: entry)
        case .accessoryRectangular:
            StatsAccessoryRectangularView(entry: entry)
        case .accessoryCircular:
            StatsAccessoryCircularView(entry: entry)
        case .accessoryInline:
            StatsAccessoryInlineView(entry: entry)
        default:
            Text("🥲")
        }
    }
}

struct StatsDueSmallView: View {
    var entry: TodayStatsEntry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color.widgetBGColor)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.widgetTextColor)
                            .frame(width: 45)
                        Image(systemName: "clock.badge.exclamationmark")
                            .font(.title2)
                            .foregroundColor(Color.white)
                    }
                    .padding([.leading, .top])
                    Spacer()
                    Text("Due")
                        .font(.title3)
                        .padding([.trailing, .top])
                }
                Spacer()
                HStack {
                    Spacer()
                    Text("\(entry.dueCount)")
                        .font(.largeTitle)
                        .bold()
                        .padding([.trailing, .bottom])
                }
            }
        }
    }
}

struct StatsDueReviewedSmallView: View {
    var entry: TodayStatsEntry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color.widgetBGColor)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.widgetTextColor)
                            .frame(width: 45)
                        Image(systemName: "clock.badge.exclamationmark")
                            .font(.title2)
                            .foregroundColor(Color.white)
                    }
                    .padding([.leading])
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(entry.dueCount)")
                            .font(.title3)
                            .padding([.trailing])
                        Text("Due")
                            .font(.subheadline)
                            .bold()
                            .padding([.trailing])
                    }
                }
                .frame(maxHeight: .infinity)
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.widgetTextColor)
                            .frame(width: 45)
                        Image(systemName: "arrow.2.circlepath")
                            .font(.title2)
                            .foregroundColor(Color.white)
                    }
                    .padding([.leading])
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(entry.reviewedCount)")
                            .font(.title3)
                            .padding([.trailing])
                        Text("Reviewed")
                            .font(.subheadline)
                            .bold()
                            .padding([.trailing])
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
    }
}

struct StatsMediumWidgetView: View {
    let entry: TodayStatsEntry
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color.widgetBGColor)
            VStack {
                Text("Today's Stats")
                    .font(.title2)
                    .bold()
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                    .foregroundColor(Color.widgetTextColor)
                HStack(alignment: .center) {
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
                    .padding(.bottom, 8)
                }
                Button(action: {
                    
                }, label: {
                    Text("Study Due Words")
                        .bold()
                        .foregroundColor(.white)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(Color.widgetTextColor.gradient)
                        .cornerRadius(20)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 8)
                })
                Spacer()
            }
        }
    }
}

struct StatsAccessoryRectangularView: View {
    let entry: TodayStatsEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .widgetAccentable()
                    .bold()
                    .frame(width: 20)
                Text("Rev")
                Spacer()
                Text("\(entry.reviewedCount)")
            }
            HStack {
                Image(systemName: "clock.badge.exclamationmark")
                    .widgetAccentable()
                    .bold()
                    .frame(width: 20)
                Text("Due")
                Spacer()
                Text("\(entry.dueCount)")
            }
        }
    }
}

struct StatsAccessoryCircularView: View {
    let entry: TodayStatsEntry
    
    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "clock.badge.exclamationmark")
                Text("\(entry.dueCount)")
                    .font(.title3)
            }
        }
    }
}

struct StatsAccessoryInlineView: View {
    let entry: TodayStatsEntry
    
    var body: some View {
        Label("\(entry.dueCount)", systemImage: "clock.badge.exclamationmark")
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
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryCircular,
            .accessoryInline
        ])
    }
}

struct TodayStatsWidget_Previews: PreviewProvider {
    static var previews: some View {
        TodayStatsWidgetEntryView(entry: TodayStatsEntry(date: Date(), reviewedCount: 235, parsedCount: 25, newCount: 75, dueCount: 45))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
