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
    @State var selectedPerson: PersonType = .none
    @State var selectedGender: GenderType = .masculine
    @State var selectedNumber: NumberType = .singular
    @State var paradigms: [HebrewParadigm] = []
    @State var currentParadigmIndex = 0
    @State var answerMode = AnswerMode.answering
    
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
                    .cornerRadius(6)
                    .padding(.top)
                    .padding(.horizontal)
                    Text(currentParadigm?.text ?? "")
                        .font(.bible60)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .background(Color(UIColor.systemBackground))
                        .foregroundColor(Color(uiColor: .label))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.top)
                    if answerMode == .correct {
                        VStack(alignment: .center) {
                            Text("Correct!")
                                .font(.largeTitle)
                                .foregroundColor(.green)
                            Text(currentParadigm?.parsing(display: .long) ?? "")
                                .font(.title2)
                                .foregroundColor(.green)
                                .bold()
                                .padding(.bottom)
                            Text("Definition:")
                            Text(currentParadigm?.def ?? "")
                                .font(.title3)
                                .bold()
                        }
                    }
                    if answerMode == .wrong {
                        VStack(alignment: .center) {
                            Text("Incorrect!")
                                .font(.largeTitle)
                                .foregroundColor(.red)
                                .padding(.bottom)
                            Text("Correct Answer:")
                            Text(currentParadigm?.parsing(display: .long) ?? "")
                                .font(.title2)
                                .bold().padding(.bottom)
                            Text("Definition:")
                            Text(currentParadigm?.def ?? "")
                                .font(.title3)
                                .bold()
                        }
                    }
                    Spacer()
                    VStack {
                        Picker("Select Person", selection: $selectedPerson) {
                            ForEach(PersonType.allCases, id: \.self) { person in
                                Text(person.mediumTitle)
                            }
                        }.pickerStyle(.segmented)
                        Picker("Select Gender", selection: $selectedGender) {
                            ForEach(GenderType.allCases, id: \.self) { gender in
                                Text(gender.mediumTitle)
                            }
                        }.pickerStyle(.segmented)
                        Picker("Select Number", selection: $selectedNumber) {
                            ForEach(NumberType.allCases, id: \.self) { number in
                                Text(number.mediumTitle)
                            }
                        }.pickerStyle(.segmented)
                            .padding(.bottom)
                        
                        AppButton(text: answerMode == .answering ? "Check Answer" : "Next", action: onButtonTap)
                            .padding(.bottom)
                    }
                    .padding(.horizontal)
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
}

extension ParadigmPracticeView {
    
    enum AnswerMode {
        case correct
        case wrong
        case answering
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
    
    func onButtonTap() {
        if [AnswerMode.wrong, AnswerMode.correct].contains(answerMode) {
            setNextParadigm()
            answerMode = .answering
        } else {
            if selectedPerson == currentParadigm?.person &&
                selectedGender == currentParadigm?.gender &&
                selectedNumber == currentParadigm?.number {
                answerMode = .correct
            } else {
                answerMode = .wrong
            }
        }
    }
}

struct ParadigmPracticeView_Previews: PreviewProvider {
    static var previews: some View {
        ParadigmPracticeView(paradigmTypes: [.qatalStrong])
    }
}
