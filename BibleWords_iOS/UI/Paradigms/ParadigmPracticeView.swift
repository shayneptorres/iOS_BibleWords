//
//  ParadigmPracticeView.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/26/22.
//

import SwiftUI
import Foundation

struct ParadigmPracticeView: View {
    struct Entry: Identifiable {
        let id = UUID().uuidString
        let item: LanguageConcept.Item
        let answerType: SessionEntryAnswerType
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let paradigmTypes: [HebrewConcept]
    @State var currentParadigm: LanguageConcept.Item?
    @State var paradigms: [LanguageConcept.Item] = []
    @State var currentParadigmIndex = 0
    @State var displayMode = DisplayMode.testing
    @State var entries: [Entry] = []
    @State var showCurrentEntries = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .secondarySystemBackground)
                    .ignoresSafeArea()
                if horizontalSizeClass == .compact {
                    VStack {
                        HeaderView()
                            .onTapGesture {
                                showCurrentEntries = true
                            }
                        TextCardView()
                        if displayMode == .showingAnswer {
                            DefinitionView()
                        }
                        if displayMode == .showingAnswer {
                            AnswerView()
                        } else {
                            TapToRevealView()
                        }
                    }
                } else {
                    GeometryReader { proxy in
                        HStack {
                            VStack {
                                HeaderView()
                                TextCardView()
                                if displayMode == .showingAnswer {
                                    DefinitionView()
                                }
                                Spacer()
                            }
                            .frame(width: proxy.size.width * 0.60)
                            .frame(maxHeight: .infinity)
                            if displayMode == .showingAnswer {
                                AnswerView()
                                    .padding()
                            } else {
                                TapToRevealView()
                                    .padding()
                            }
                        }
                    }
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
            .sheet(isPresented: $showCurrentEntries) {
                NavigationStack {
                    List(entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.item.text)
                                .font(.bible32)
                            Text(entry.item.details)
                            Text(entry.item.definition)
                            HStack {
                                entry.answerType.rowImage
                                    .padding(.trailing, 4)
                                Text(entry.answerType.title)
                                    .foregroundColor(entry.answerType.color)
                                Spacer()
                            }
                        }
                    }
                    .toolbar {
                        Button(action: {
                            if currentParadigmIndex == paradigms.count - 1 {
                                showCurrentEntries = false
                                presentationMode.wrappedValue.dismiss()
                            }
                        }, label: {
                            Text("Dismiss")
                                .bold()
                        })
                    }
                    .navigationBarTitle(currentParadigmIndex == paradigms.count - 1 ? "Study Report" : "Current Progress")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                paradigms = paradigmTypes.flatMap { $0.group.items }.shuffled().filter { $0.text != "_" }
                setCurrentParadigm()
            }
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
    
    func HeaderView() -> some View {
        HStack(alignment: .center) {
            VStack {
                Text("Paradigm \(currentParadigmIndex + 1) out of \(paradigms.count)")
                    .bold()
                    .padding(.bottom, 4)
                HStack {
                    HStack {
                        SessionEntryAnswerType.wrong.rowImage
                        Text("\(entries.filter { $0.answerType == .wrong }.count)")
                    }
                    .frame(maxWidth: .infinity)
                    HStack {
                        SessionEntryAnswerType.hard.rowImage
                        Text("\(entries.filter { $0.answerType == .hard }.count)")
                    }
                    .frame(maxWidth: .infinity)
                    HStack {
                        SessionEntryAnswerType.good.rowImage
                        Text("\(entries.filter { $0.answerType == .good }.count)")
                    }
                    .frame(maxWidth: .infinity)
                    HStack {
                        SessionEntryAnswerType.easy.rowImage
                        Text("\(entries.filter { $0.answerType == .easy }.count)")
                    }
                    .frame(maxWidth: .infinity)
                }
                .font(.caption)
            }
        }
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity, minHeight: 40)
        .background(Color(uiColor: .systemGray))
        .cornerRadius(Design.smallCornerRadius)
        .padding(.horizontal)
    }
    
    func TextCardView() -> some View {
        Text(currentParadigm?.text ?? "")
            .font(.bible100)
            .minimumScaleFactor(0.6)
            .frame(maxWidth: .infinity, maxHeight: 200)
            .background(Color(UIColor.systemBackground))
            .foregroundColor(Color(uiColor: .label))
            .cornerRadius(Design.defaultCornerRadius)
            .padding(.horizontal)
            .padding(.top, 4)
    }
    
    func DefinitionView() -> some View {
        HStack {
            Text(currentParadigm?.details ?? "")
                .font(.bible24)
                .padding(.trailing, 8)
            Text(currentParadigm?.definition ?? "")
                .font(.bible24)
        }
    }
    
    func AnswerView() -> some View {
        return AnyView(
            VStack {
                Spacer()
                HStack {
                    AnswerButton(answerType: .wrong, action: { on(.wrong) })
                    AnswerButton(answerType: .hard, action: { on(.hard) })
                }
                .frame(maxWidth: .infinity)
                HStack {
                    AnswerButton(answerType: .good, action: { on(.good) })
                    AnswerButton(answerType: .easy, action: { on(.easy) })
                }
                .frame(maxWidth: .infinity)
            }
                .frame(maxWidth: .infinity)
        )
        .frame(maxHeight: .infinity)
        .padding([.horizontal, .bottom], 8)
    }
    
    func on(_ answer: SessionEntryAnswerType) {
        self.entries.append(.init(item: currentParadigm!, answerType: answer))
        onTapNext()
    }
    
    func AnswerButton(answerType: SessionEntryAnswerType, action: @escaping (() -> ())) -> some View {
        return Button(action: action, label: {
            VStack {
                answerType.buttonImage
                    .font(.largeTitle)
                    .padding(.bottom, 4)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(answerType.color)
            .cornerRadius(Design.defaultCornerRadius)
        })
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
//            presentationMode.wrappedValue.dismiss()
            showCurrentEntries = true
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
