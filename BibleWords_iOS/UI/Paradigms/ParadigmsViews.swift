//
//  ParadigmsViews.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/25/22.
//

import SwiftUI

struct ConceptsView: View {
    enum Mode {
        case singleSelect
        case multiSelect
    }
    
    @State var selectedConcepts: [HebrewConcept] = []
    @State var mode: Mode = .singleSelect
    @State var showParadigmDetailView = false
    
    var body: some View {
        ZStack {
            List {
                ForEach(HebrewConceptGroup.allCases, id: \.rawValue) { group in
                    Section {
                        ForEach(group.concepts, id: \.rawValue) { concept in
                            if mode == .singleSelect {
                                NavigationLink(destination: ParadigmDetailView(concepts: [concept]), label: {
                                    Text(concept.group.title)
                                })
                            } else {
                                Button(action: { onTap(concept) }, label: {
                                    HStack {
                                        Text(concept.group.title)
                                            .foregroundColor(Color(uiColor: .label))
                                        Spacer()
                                        if selectedConcepts.contains(concept) {
                                            Image(systemName: "circle.dashed.inset.filled")
                                                .foregroundColor(.accentColor)
                                        } else {
                                            Image(systemName: "circle.dashed")
                                        }
                                    }
                                })
                            }
                        }
                    } header: {
                        Text(group.title)
                    }
                }
            }
        }
        // TODO: update this view so user can actually use this view
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if mode == .multiSelect {
                    Button(action: {
                        mode = .singleSelect
                        selectedConcepts.removeAll()
                    }, label: {
                        Text("Cancel").bold()
                    })
                }
            }
            ToolbarItem(placement: .primaryAction) {
                if mode == .singleSelect {
                    Button(action: {
                        mode = .multiSelect
                    }, label: {
                        Text("Select").bold()
                    })
                } else {
                    Button(action: {
                        showParadigmDetailView = true
                    }, label: {
                        Text("Practice").bold()
                    })
                    .disabled(selectedConcepts.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showParadigmDetailView) {
            NavigationView {
                ParadigmDetailView(concepts: selectedConcepts)
                    .toolbar {
                        Button(action: {
                            showParadigmDetailView = false
                        }, label: {
                            Text("Dismiss")
                                .bold()
                        })
                    }
            }
        }
        .navigationTitle("Hebrew Paradigms")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            mode = .singleSelect
            selectedConcepts.removeAll()
        }
    }
    
    func onTap(_ paradigm: HebrewConcept) {
        if let index = selectedConcepts.firstIndex(of: paradigm) {
            selectedConcepts.remove(at: index)
        } else {
            selectedConcepts.append(paradigm)
        }
    }
    
    func ButtonView() -> some View {
        VStack {
            Spacer()
            if mode == .singleSelect {
                AppButton(text: "Select Multiple Paradigms", action: { mode = .multiSelect })
                    .padding(.bottom)
                    .padding(.horizontal)
            }
            if mode == .multiSelect {
                AppButton(text: "Practice \(selectedConcepts.count) Paradigms", action: { showParadigmDetailView = true })
                    .disabled(mode == .multiSelect && selectedConcepts.isEmpty)
                    .padding(.horizontal)
                AppButton(text: "Cancel", type: .secondary, action: {
                    mode = .singleSelect
                    selectedConcepts.removeAll()
                })
                .padding(.bottom)
                .padding(.horizontal)
            }
        }
    }
}

struct ParadigmsViews_Previews: PreviewProvider {
    static var previews: some View {
        ConceptsView()
    }
}
