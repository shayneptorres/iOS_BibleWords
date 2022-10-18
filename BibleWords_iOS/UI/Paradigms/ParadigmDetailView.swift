//
//  ParadigmDetailView.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/25/22.
//

import SwiftUI

struct ParadigmDetailView: View {
    let paradigmTypes: [HebrewParadigmType]
    let gridItemLayout: [GridItem] = [.init(.flexible()),.init(.flexible())]
    @State var showPracticeView = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            ScrollView {
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(paradigmTypes, id: \.rawValue) { type in
                        Section(content: {
                            ForEach(type.group.paradigms) { paradigm in
                                VStack {
                                    Text(paradigm.text)
                                        .font(.bible50)
                                        .padding(.bottom, 4)
                                    Text(paradigm.parsing(display: .short))
                                    Text(paradigm.def)
                                }
                                .frame(maxWidth: .infinity, minHeight: 150)
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
                .padding(.bottom)
            }
        }
        .sheet(isPresented: $showPracticeView) {
            ParadigmPracticeView(paradigmTypes: paradigmTypes)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var paradigms: [HebrewParadigm] {
        return paradigmTypes.flatMap { $0.group.paradigms }
    }
    
    var title: String {
        if paradigmTypes.count == 1 {
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
            ParadigmDetailView(paradigmTypes: [.qatalStrong])
        }
    }
}
