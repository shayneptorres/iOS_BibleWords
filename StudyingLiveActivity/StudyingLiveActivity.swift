//
//  StudyingLiveActivity.swift
//  StudyingLiveActivity
//
//  Created by Shayne Torres on 10/26/22.
//

import WidgetKit
import SwiftUI
import ActivityKit

//struct StudyingLiveActivityEntryView : View {
//
//    var body: some View {
//        Text(entry.date, style: .time)
//    }
//}

@available(iOSApplicationExtension 16.1, *)
struct StudyActivityView: View {
    let context: ActivityViewContext<StudyAttributes>
    @State var currentDate = Date()
    @State var timerStr = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Bible Words")
                    .foregroundColor(.accentColor)
                    .font(.subheadline)
                    .bold()
                    .padding(.bottom, 4)
                Text("Vocab Study Session")
                Text("Due Words: \(context.state.dueCount)")
                    .font(.subheadline)
                Text("New Words: \(context.state.newCount)")
                    .font(.subheadline)
            }
            Spacer()
            Text(context.state.text)
                .font(.bible40)
        }
        .padding()
    }
}

@main
@available(iOSApplicationExtension 16.1, *)
struct StudyingLiveActivity: Widget {
    let kind: String = "StudyingLiveActivity"
    private let btnHeight: CGFloat = 45
    private let btnWidth: CGFloat = 60
    private let radius: CGFloat = 0

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StudyAttributes.self, content: { context in
            StudyActivityView(context: context)
        }, dynamicIsland: { context in
            DynamicIsland(expanded: {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                        Text("Words Due: \(context.state.dueCount)")
                            .font(.subheadline)
                        Text("New Due: \(context.state.newCount)")
                            .font(.subheadline)
                    }
                    .padding(4)
                }
                
                DynamicIslandExpandedRegion(.trailing, priority: 1) {
                    Text(context.state.text)
                        .font(.bible40)
                        .minimumScaleFactor(0.5)
                        .padding(.trailing, 4)
                        .dynamicIsland(verticalPlacement: .belowIfTooWide)
                }
            }, compactLeading: {
                Text("Studying: ")
            }, compactTrailing: {
                Text(context.state.text)
                    .font(.bible20)
            }, minimal: {
                Text("ּא|ω")
                    .font(.bible17)
                    .foregroundColor(.accentColor)
            })
        })
    }
}


//struct StudyingLiveActivity_Previews: PreviewProvider {
//    static var previews: some View {
//        StudyActivityView(context: .init)
//    }
//}
