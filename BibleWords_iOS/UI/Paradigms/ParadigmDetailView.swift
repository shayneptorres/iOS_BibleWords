//
//  ParadigmDetailView.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/25/22.
//

import SwiftUI

struct ParadigmDetailView: View {
    let concepts: [HebrewConcept]
    let gridItemLayout: [GridItem] = [.init(.flexible()),.init(.flexible())]
    @State var showPracticeView = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            ScrollView {
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(concepts, id: \.rawValue) { type in
                        Section(content: {
                            ForEach(type.group.items) { paradigm in
                                VStack(alignment: .center, spacing: 8) {
                                    Text(paradigm.text)
                                        .font(.bible50)
                                        .padding(.bottom)
                                    if !paradigm.parsing.isEmpty {
                                        Text(paradigm.parsing)
                                            .multilineTextAlignment(.center)
                                            .padding(.bottom)
                                    }
                                    if !paradigm.definition.isEmpty {
                                        Text(paradigm.definition)
                                            .multilineTextAlignment(.center)
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, minHeight: 225)
                                .padding(.top)
                                .padding(.horizontal)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .foregroundColor(Color(uiColor: .label))
                                .cornerRadius(Design.defaultCornerRadius)
                            }
                        }, header: {
                            Text(type.group.title)
                                .bold()
                                .padding(8)
                        })
                    }
                    Spacer().frame(height: 150)
                }
                .padding(.horizontal)
            }
        }
        .fullScreenCover(isPresented: $showPracticeView) {
            ParadigmPracticeView(paradigmTypes: concepts)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(action: {
                showPracticeView = true
            }, label: {
                Label("Study", systemImage: "brain.head.profile")
            })
            .labelStyle(.titleAndIcon)
        }
    }
    
    var paradigms: [LanguageConcept.Item] {
        return concepts.flatMap { $0.group.items }
    }
    
    var title: String {
        if concepts.count == 1 {
//            return paradigms.first?.text ?? ""
            return ""
        } else {
            return "Multiple Paradigms"
        }
    }
    
}

struct ParadigmDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ParadigmDetailView(concepts: [.qatalStrong])
        }
    }
}
