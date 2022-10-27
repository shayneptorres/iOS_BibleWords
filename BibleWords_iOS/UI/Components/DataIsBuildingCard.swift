//
//  DataIsBuildingCard.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/27/22.
//

import SwiftUI

struct DataIsBuildingCard: View {
    @Binding var rotationAngle: CGFloat
    var body: some View {
        HStack {
            Image(systemName: "hammer")
                .font(.headline)
                .foregroundColor(.accentColor)
                .rotationEffect(.degrees(rotationAngle))
                .animation(.easeOut(duration: 1), value: rotationAngle)
                .padding(.trailing)
            Text("Building bible data...")
                .font(.title3)
                .fontWeight(.semibold)
        }
        .appCard(height: 10)
    }
}

struct DataIsBuildingCard_Previews: PreviewProvider {
    static var previews: some View {
        DataIsBuildingCard(rotationAngle: .constant(90))
    }
}
