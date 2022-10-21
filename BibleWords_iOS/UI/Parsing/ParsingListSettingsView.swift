//
//  ParsingListSettingsView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/20/22.
//

import SwiftUI

struct ParsingListSettingsView: View {
    enum SettingPage: Int, Hashable {
        case sessionReports
    }
    
    @Binding var list: ParsingList
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(value: SettingPage.sessionReports) {
                    Text("Session Reports")
                }
            }
            .onAppear {
                print(list.sessionsArr.count)
                print(list.studySessions?.count ?? 0)
                print(list)
                print(list.defaultTitle)
            }
            .navigationDestination(for: SettingPage.self) { setting in
                switch setting {
                case .sessionReports:
                    ParsingListSessionsView(list: $list)
//                    List {
//                        Text("Look!")
//                        Text("Count: \(list.defaultTitle)")
//                        ForEach(list.sessionsArr) { session in
//                            NavigationLink(value: session) {
//                                Text(session.startDate?.toPrettyDate ?? "")
//                            }
//                        }
//                    }
                }
            }
        }
    }
}

//struct ParsingListSetting_Previews: PreviewProvider {
//    static var previews: some View {
//        ParsingListSettingsView()
//    }
//}
