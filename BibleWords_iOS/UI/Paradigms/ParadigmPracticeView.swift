//
//  ParadigmPracticeView.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/26/22.
//

import SwiftUI

struct ParadigmPracticeView: View {
    @Environment(\.presentationMode) var presentationMode
    let paradigmTypes: [HebrewParadigmType]
    @State var currentParadigm: HebrewParadigm?
//    @State var selectedPerson: PersonType = .none
//    @State var selectedGender: GenderType = .masculine
//    @State var selectedNumber: NumberType = .singular
    @State var paradigms: [HebrewParadigm] = []
    @State var currentParadigmIndex = 0
    @State var displayMode = DisplayMode.testing
//    @State var answerMode = AnswerMode.answering
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .secondarySystemBackground)
                    .ignoresSafeArea()
                VStack {
                    HStack(alignment: .center) {
                        Text("Paradigm \(currentParadigmIndex + 1) out of \(paradigms.count)")
                            .bold()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(Color(uiColor: .systemGray))
                    .cornerRadius(Design.smallCornerRadius)
                    .padding(.top)
                    .padding(.horizontal)
                    Text(currentParadigm?.text ?? "")
                        .font(.bible100)
                        .minimumScaleFactor(0.6)
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .background(Color(UIColor.systemBackground))
                        .foregroundColor(Color(uiColor: .label))
                        .cornerRadius(Design.defaultCornerRadius)
                        .padding(.horizontal)
                        .padding(.top, 4)
                    if displayMode == .showingAnswer {
                        VStack(alignment: .center) {
                            Text(currentParadigm?.parsing(display: .long) ?? "")
                                .font(.title2)
                                .foregroundColor(.appOrange)
                                .bold()
                                .padding(.bottom)
                            Text("Definition:")
                            Text(currentParadigm?.def ?? "")
                                .font(.title3)
                                .bold()
                        }
                    }
                    TapToRevealView()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    VStack {
                        Text(title)
                        Text(subtitle)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }, label: {
                        Text("Done")
                    })
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            paradigms = paradigmTypes.flatMap { $0.group.paradigms }.shuffled().filter { $0.text != "_" }
            setCurrentParadigm()
        }
    }
    
    var title: String {
        return "Paradigm Practice"
    }
    
    var subtitle: String {
        if paradigmTypes.count == 1 {
            return paradigmTypes.first!.group.title
        } else {
            return "Multiple Paradigms"
        }
    }
    
    func TapToRevealView() -> some View {
        return AnyView(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text(displayMode == .testing ? "Tap to Reveal" : "Next")
                        .foregroundColor(.accentColor)
                        .font(.title2)
                        .bold()
                    Spacer()
                }
                Spacer()
            }
                .background(Color.red.opacity(0.0001))
                .onTapGesture {
                    if displayMode == .testing {
                        onTapToReveal()
                    } else {
                        onTapNext()
                    }
                }
        )
    }
}

extension ParadigmPracticeView {
    
    enum AnswerMode {
        case correct
        case wrong
        case answering
    }
    
    enum DisplayMode {
        case testing
        case showingAnswer
    }
    
    func setCurrentParadigm() {
        currentParadigm = paradigms[currentParadigmIndex]
    }
    
    func setNextParadigm() {
        if currentParadigmIndex == paradigms.count - 1 {
            presentationMode.wrappedValue.dismiss()
        } else {
            currentParadigmIndex += 1
            setCurrentParadigm()
        }
    }
    
    func onTapToReveal() {
        displayMode = .showingAnswer
    }
    
    func onTapNext() {
        setNextParadigm()
        displayMode = .testing
    }
    
    
    func onButtonTap() {
//        if [AnswerMode.wrong, AnswerMode.correct].contains(answerMode) {
//            setNextParadigm()
//            answerMode = .answering
//        } else {
//            if selectedPerson == currentParadigm?.person &&
//                selectedGender == currentParadigm?.gender &&
//                selectedNumber == currentParadigm?.number {
//                answerMode = .correct
//            } else {
//                answerMode = .wrong
//            }
//        }
    }
}

struct ParadigmPracticeView_Previews: PreviewProvider {
    static var previews: some View {
        ParadigmPracticeView(paradigmTypes: [.qatalStrong])
    }
}
