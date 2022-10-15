//
//  NavHeaderTitleDetailView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/15/22.
//

import SwiftUI

struct NavHeaderTitleDetailView: View {
    var title: String
    var detail: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.subheadline)
                .foregroundColor(Color(uiColor: .secondaryLabel))
        }
    }
}

//struct NavHeaderTitleDetailView_Previews: PreviewProvider {
//    static var previews: some View {
////        NavHeaderTitleDetailView()
//    }
//}
