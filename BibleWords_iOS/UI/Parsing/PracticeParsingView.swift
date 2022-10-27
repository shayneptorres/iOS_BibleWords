//
//  PracticeParsingView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/20/22.
//

import SwiftUI

struct PracticeParsingView: View {
    enum DisplayMode {
        case surface
        case surfaceAnswer
    }
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var parsingList: ParsingList
    @State var parsingInstances: [Bible.WordInstance] = []
    @State var currentInstance: Bible.WordInstance?
    @State var currentInstanceIndex = 0
    @State var displayMode = DisplayMode.surface
    @State var showSessionReportAlert = false
//    @State var showSessionReport = false
    
    @State var session: StudySession?
    @State var entries: [StudySessionEntry] = []
    @State var startDate = Date()
    @State var endDate = Date()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .secondarySystemBackground)
                    .ignoresSafeArea()
                if horizontalSizeClass == .compact {
                    VStack {
                        HeaderView()
                        LemmaView()
                        if displayMode == .surfaceAnswer {
                            DefinitionView()
                        }
                        if displayMode == .surface {
                            TapToRevealView()
                                .padding()
                        } else {
                            Spacer()
                            AnswerView()
                                .padding()
                        }
                    }
                    
                } else {
                    GeometryReader { proxy in
                        HStack {
                            VStack {
                                HeaderView()
                                LemmaView()
                                if displayMode == .surfaceAnswer {
                                    DefinitionView()
                                }
                                Spacer()
                            }
                            .frame(width: proxy.size.width * 0.60)
                            .frame(maxHeight: .infinity)
                            if displayMode == .surface {
                                TapToRevealView()
                                    .padding()
                            } else {
                                Spacer()
                                AnswerView()
                                    .padding()
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    VStack {
                        Text("Parsing Practice")
//                        Text("DETAILS")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: onDone, label: {
                        Text("Done")
                    })
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Save Parsing Report", isPresented: $showSessionReportAlert, actions: {
                Button("Yes", action: {
                    onSave()
                })
                Button("No", role: .cancel, action: {
                    onClearUnsavedData()
                    presentationMode.wrappedValue.dismiss()
                })
            }, message: {
                Text("Would you like to save a report of this parsing session?")
            })
        }
        .interactiveDismissDisabled()
        .onAppear {
            parsingInstances = parsingInstances.shuffled()
            setCurrentInstance()
            UserDefaultKey.shouldRefreshWidgetTimeline.set(val: true)
            CoreDataManager.transactionAsync(context: context) {
                self.parsingList.lastStudied = Date()
            }
        }
    }
}

extension PracticeParsingView {
    
    func DefinitionView() -> some View {
        VStack(alignment: .center) {
            Text(currentInstance?.displayParsingStr ?? "")
                .multilineTextAlignment(.center)
                .font(.title3)
                .bold()
                .padding(.bottom)
            HStack {
                VStack(alignment: .center) {
                    Text("Lexical form:")
                        .font(.subheadline)
                        .foregroundColor(.init(uiColor: .secondaryLabel))
                    Text(currentInstance?.lemma ?? "")
                        .font(.bible24)
                }
                .frame(maxWidth: .infinity)
                VStack(alignment: .center) {
                    Text("Definition:")
                        .font(.subheadline)
                        .foregroundColor(.init(uiColor: .secondaryLabel))
                    Text(currentInstance?.wordInfo.definition ?? "")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
    
    func LemmaView() -> some View {
        Text(currentInstance?.textSurface ?? "")
            .font(.bible72)
            .minimumScaleFactor(0.6)
            .frame(maxWidth: .infinity, maxHeight: 200)
            .background(Color(UIColor.systemBackground))
            .foregroundColor(Color(uiColor: .label))
            .cornerRadius(Design.defaultCornerRadius)
            .padding(.horizontal)
            .padding(.top, 4)
    }
    
    func HeaderView() -> some View {
        HStack(alignment: .center) {
            Text("Word \(currentInstanceIndex + 1) out of \(parsingInstances.count)")
                .bold()
        }
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity, minHeight: 40)
        .background(Color(uiColor: .systemGray))
        .cornerRadius(Design.smallCornerRadius)
        .padding(.top)
        .padding(.horizontal)
    }
    
    func TapToRevealView() -> some View {
        return AnyView(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("Tap to reveal")
                        .foregroundColor(.accentColor)
                        .font(.title2)
                        .bold()
                    Spacer()
                }
                Spacer()
            }
                .background(Color.red.opacity(0.0001))
                .onTapGesture {
                    onTapToReveal()
                }
        )
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
    
    func AnswerView() -> some View {
        return AnyView(
            VStack {
                Spacer()
                HStack {
                    AnswerButton(answerType: .wrong, action: onWrong)
                    AnswerButton(answerType: .hard, action: onHard)
                }
                .frame(maxWidth: .infinity)
                HStack {
                    AnswerButton(answerType: .good, action: onCorrect)
                    AnswerButton(answerType: .easy, action: onEasy)
                }
                .frame(maxWidth: .infinity)
            }
                .frame(maxWidth: .infinity)
        )
        .frame(maxHeight: 300)
    }
}

extension PracticeParsingView {
    func onWrong() {
        CoreDataManager.transaction(context: context) {
            let entry = StudySessionEntry.new(context: context, word: currentInstance?.wordInfo.vocabWord(context: context), answer: .wrong, studyType: .parsing)
            entry.relatedId = currentInstance?.id
            entry.studiedText = currentInstance?.textSurface
            entry.studiedDetail = currentInstance?.displayParsingStr
            entry.studiedDescription = currentInstance?.lemma
            entries.append(entry)
            
            setNextInstance()
        }
    }
    
    func onHard() {
        CoreDataManager.transaction(context: context) {
            let entry = StudySessionEntry.new(context: context, word: currentInstance?.wordInfo.vocabWord(context: context), answer: .hard, studyType: .parsing)
            entry.relatedId = currentInstance?.id
            entry.studiedText = currentInstance?.textSurface
            entry.studiedDetail = currentInstance?.displayParsingStr
            entry.studiedDescription = currentInstance?.lemma
            entries.append(entry)
            
            setNextInstance()
        }
    }
    
    func onCorrect() {
        CoreDataManager.transaction(context: context) {
            let entry = StudySessionEntry.new(context: context, word: currentInstance?.wordInfo.vocabWord(context: context), answer: .good, studyType: .parsing)
            entry.relatedId = currentInstance?.id
            entry.studiedText = currentInstance?.textSurface
            entry.studiedDetail = currentInstance?.displayParsingStr
            entry.studiedDescription = currentInstance?.lemma
            entries.append(entry)
            
        }
        setNextInstance()
    }
    
    func onEasy() {
        CoreDataManager.transaction(context: context) {
            let entry = StudySessionEntry.new(context: context, word: currentInstance?.wordInfo.vocabWord(context: context), answer: .easy, studyType: .parsing)
            entry.relatedId = currentInstance?.id
            entry.studiedText = currentInstance?.textSurface
            entry.studiedDetail = currentInstance?.displayParsingStr
            entry.studiedDescription = currentInstance?.lemma
            entries.append(entry)
            
        }
        setNextInstance()
    }
    
    func setCurrentInstance() {
        currentInstance = parsingInstances[currentInstanceIndex]
    }
    
    func setNextInstance() {
        if currentInstanceIndex == parsingInstances.count - 1 {
            presentationMode.wrappedValue.dismiss()
        } else {
            currentInstanceIndex += 1
            setCurrentInstance()
        }
        displayMode = .surface
    }
    
    func onTapToReveal() {
        displayMode = .surfaceAnswer
    }
    
    func onTapNext() {
        setNextInstance()
        displayMode = .surface
    }
    
    func onDone() {
        showSessionReportAlert = true
    }
    
    func onClearUnsavedData() {
        for obj in context.insertedObjects {
            context.delete(obj)
        }
    }
    
    func onSave() {
        endDate = Date()
        
        // create session
        CoreDataManager.transactionAsync(context: context) {
            let session = StudySession(context: context)
            session.id = UUID().uuidString
            session.startDate = startDate
            session.endDate = endDate
            session.parsingList = parsingList
            session.activityTypeInt = ActivityType.parsing.rawValue
            session.activityTitle = parsingList.title ?? ""
            
            for entry in entries {
                // add entries
                session.addToEntries(entry)
            }
            self.session = session
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct PracticeParsingView_Previews: PreviewProvider {
    static var previews: some View {
        PracticeParsingView(parsingList: .init(context: PersistenceController.preview.container.viewContext))
    }
}
