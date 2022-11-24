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
        NavigationView {
            List {
                NavigationLink(destination: {
                    ParsingListSessionsView(list: $list)
                }, label: {
                    Text("Session Reports")
                })
            }
            .onAppear {
            }
        }
    }
}

//struct ParsingListSetting_Previews: PreviewProvider {
//    static var previews: some View {
//        ParsingListSettingsView()
//    }
//}
