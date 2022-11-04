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
                HStack {
                    Text("Study Session Reports")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .foregroundColor(Color(uiColor: .label))
                .cornerRadius(Design.defaultCornerRadius)
                .padding()
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(concepts, id: \.rawValue) { type in
                        Section(content: {
                            ForEach(type.group.items) { paradigm in
                                VStack(alignment: .center, spacing: 4) {
                                    Text(paradigm.text)
                                        .font(.bible50)
                                    Text(paradigm.details)
                                        .font(.bible20)
                                        .multilineTextAlignment(.center)
                                    Text(paradigm.definition)
                                        .font(.bible20)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity, minHeight: 225)
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
            VStack {
                Spacer()
                AppButton(text: "Practice Paradigms", action: {
                    showPracticeView = true
                })
                .padding([.horizontal, .bottom])
            }
        }
        .fullScreenCover(isPresented: $showPracticeView) {
            ParadigmPracticeView(paradigmTypes: concepts)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var paradigms: [LanguageConcept.Item] {
        return concepts.flatMap { $0.group.items }
    }
    
    var title: String {
        if concepts.count == 1 {
//            return paradigmTypes.first!.group.title
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
