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
            }
            .navigationDestination(for: SettingPage.self) { setting in
                switch setting {
                case .sessionReports:
                    ParsingListSessionsView(list: $list)
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
