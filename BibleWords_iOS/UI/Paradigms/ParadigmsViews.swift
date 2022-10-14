//
//  ParadigmsViews.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/25/22.
//

import SwiftUI

struct ParadigmsViews: View {
    
    enum Mode {
        case singleSelect
        case multiSelect
    }
    
    @State var selectedParadigms: [HebrewParadigmType] = []
    @State var mode: Mode = .singleSelect
    @State var showParadigmDetailView = false
    
    var body: some View {
        ZStack {
            if mode == .singleSelect {
                List {
                    Section {
                        ForEach(HebrewParadigmType.allCases, id: \.self) { paradigm in
                            NavigationLink(destination: ParadigmDetailView(paradigmTypes: [paradigm]), label: {
                                Text(paradigm.group.title)
                            })
                        }
                    } footer: {
                        Spacer().frame(height: 75)
                    }
                }
            }
            if mode == .multiSelect {
                List {
                    Section {
                        ForEach(HebrewParadigmType.allCases, id: \.self) { paradigm in
                            Button(action: { onTap(paradigm) }, label: {
                                HStack {
                                    Text(paradigm.group.title)
                                        .foregroundColor(Color(uiColor: .label))
                                    Spacer()
                                    Image(systemName: selectedParadigms.contains(paradigm) ? "circle.dashed.inset.filled" : "circle.dashed")
                                }
                            })
                        }
                    } footer: {
                        Spacer().frame(height: 150)
                    }
                }
            }
            VStack {
                Spacer()
                if mode == .singleSelect {
                    AppButton(text: "Select Multiple Paradigms", action: { mode = .multiSelect })
                        .padding(.bottom)
                }
                if mode == .multiSelect {
                    
                    AppButton(text: "Practice \(selectedParadigms.count) Paradigms", action: { showParadigmDetailView = true })
                        .disabled(mode == .multiSelect && selectedParadigms.isEmpty)
                    AppButton(text: "Cancel", type: .secondary, action: {
                        mode = .singleSelect
                        selectedParadigms.removeAll()
                    })
                    .padding(.bottom)
                }
            }
        }
        .navigationDestination(isPresented: $showParadigmDetailView) {
            ParadigmDetailView(paradigmTypes: selectedParadigms)
        }
        .navigationTitle("Hebrew Paradigms")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            mode = .singleSelect
            selectedParadigms.removeAll()
        }
    }
    
    func onTap(_ paradigm: HebrewParadigmType) {
        if let index = selectedParadigms.firstIndex(of: paradigm) {
            selectedParadigms.remove(at: index)
        } else {
            selectedParadigms.append(paradigm)
        }
    }
}

struct ParadigmsViews_Previews: PreviewProvider {
    static var previews: some View {
        ParadigmsViews()
    }
}
