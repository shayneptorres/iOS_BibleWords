//
//  ParsingLists.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/18/22.
//

import SwiftUI

struct ParsingLists: View {
    @State var showBuildParingList = false
    var body: some View {
        ZStack {
            List {
                
            }
            VStack {
                Spacer()
                AppButton(text: "Create new list") {
                    showBuildParingList = true
                }
            }
        }
        .sheet(isPresented: $showBuildParingList) {
            NavigationStack {
                BuildParsingListView()
            }
        }
        .navigationTitle("Parsing Lists")
    }
}

struct ParsingLists_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ParsingLists()
        }
    }
}
