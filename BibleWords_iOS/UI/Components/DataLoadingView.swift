//
//  DataLoadingRow.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/17/22.
//

import SwiftUI

struct DataLoadingRow: View {
    var body: some View {
        HStack {
            ProgressView()
                .progressViewStyle(.automatic)
                .padding(.trailing)
            Text("Building bible words data...")
        }
    }
}

struct DataLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        DataLoadingRow()
    }
}
