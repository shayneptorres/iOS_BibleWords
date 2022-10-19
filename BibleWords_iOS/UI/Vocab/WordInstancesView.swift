//
//  WordInstancesView.swift
//  Bible_Words_iOS
//
//  Created by Shayne Torres on 10/11/22.
//

import SwiftUI

struct WordInstancesView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var word: Bible.WordInfo
    @State var showForms = true
    @State var showAppearances = true
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Text("lemma")
                        .font(.headline)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                    Text(word.lemma)
                        .font(.bible40)
                }
                VStack(alignment: .leading) {
                    Text("definition")
                        .font(.headline)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                    Text(word.definition)
                }
            } header: {
                Text("Word info")
            }
            Section {
                if showForms {
                    ForEach(word.parsingInfo.instances.sorted { $0.parsing < $1.parsing }) { info in
                        HStack {
                            Text(info.textSurface)
                                .font(info.language == .greek ? .bible24 : .bible32)
                            Spacer()
                            Text(info.parsing)
                                .font(.footnote)
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                        }
                    }
                }
            } header: {
                HStack {
                    Text("\(word.parsingInfo.instances.count) Forms")
                    Spacer()
                    Button(action: { showForms.toggle() }, label: {
                        Image(systemName: showForms ? "chevron.up" : "chevron.down")
                    })
                }
            }
            Section {
                if showAppearances {
                    ForEach(word.instances) { instance in
                        NavigationLink(value: instance) {
                            VStack(alignment: .leading) {
                                Text(instance.textSurface)
                                    .font(.bible24)
                                Text(instance.prettyRefStr)
                                    .font(.footnote)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                                Text(instance.parsing)
                                    .font(.footnote)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                        }
                    }
                }
            } header: {
                HStack {
                    Text("\(word.instances.count) Appearances")
                    Spacer()
                    Button(action: { showAppearances.toggle() }, label: {
                        Image(systemName: showAppearances ? "chevron.up" : "chevron.down")
                    })
                }
            }
        }
        .navigationDestination(for: Bible.WordInstance.self) { instance in
            WordInPassageView(word: $word, instance: instance.bound())
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Done", action: { presentationMode.wrappedValue.dismiss() })
            }
        }
    }
}

struct WordInstancesView_Previews: PreviewProvider {
    static var previews: some View {
        WordInstancesView(word: .constant(.init([:])))
    }
}
