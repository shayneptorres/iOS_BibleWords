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
    @State var showWordInPassages = false
    @State var showWordForms = false
    @State var showWordInfo = false
    
    @State var session: StudySession?
    @State var entries: [StudySessionEntry] = []
    @State var startDate = Date()
    @State var endDate = Date()
    
    var body: some View {
        NavigationView {
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
                            .bold()
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: onDone, label: {
                        Text("Done")
                            .bold()
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
        .sheet(isPresented: $showWordInfo) {
            if let wordInfo = currentInstance?.wordInfo {
                NavigationView {
                    WordInfoDetailsView(word: wordInfo.bound(), isPresentedModally: true)
                }
            } else {
                Text("Something went wrong")
            }
        }
        .sheet(isPresented: $showWordInPassages) {
            if let wordInfo = currentInstance?.wordInfo {
                NavigationView {
                    List {
                        ForEach(wordInfo.instances.filter { $0.parsing == currentInstance?.parsing ?? "" || $0.textSurface == currentInstance?.textSurface ?? "" }) { instance in
                            Section {
                                VStack(alignment: .leading, spacing: 8) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Surface Form:")
                                            .font(.subheadline)
                                            .foregroundColor(.init(uiColor: .secondaryLabel))
                                        Text(instance.textSurface)
                                            .font(instance.language.meduimBibleFont)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Parsing:")
                                            .font(.subheadline)
                                            .foregroundColor(.init(uiColor: .secondaryLabel))
                                        Text(instance.displayParsingStr)
                                    }
                                    .padding(.bottom)
                                    Text(instance.prettyRefStr)
                                        .font(.title3)
                                        .bold()
                                    Text(instance.wordInPassage) { string in
                                        let attributedStr = instance.textSurface
                                        if let range = string.range(of: attributedStr) { /// here!
                                            string[range].foregroundColor = .accentColor
                                        }
                                    }
                                    .font(instance.language.largeBibleFont)
                                }
                            }
                        }
                    }
                    .navigationBarTitle("Appearances", displayMode: .inline)
                    .toolbar {
                        Button(action: {
                            showWordInPassages = false
                        }, label: {
                            Text("Dimiss")
                                .bold()
                        })
                    }
                }
            } else {
                Text("Something went wrong")
            }
        }
        .sheet(isPresented: $showWordForms) {
            if let wordInfo = currentInstance?.wordInfo {
                NavigationView {
                    List {
                        ForEach(wordInfo.parsingInfo.instances.sorted { $0.parsing < $1.parsing }) { info in
                            NavigationLink(destination: {
                                WordInPassageView(word: info.wordInfo.bound(), instance: info.bound())
                            }, label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(info.textSurface)
                                        .font(info.language.meduimBibleFont)
                                        .foregroundColor(.accentColor)
                                    Text(info.parsing.capitalized)
                                        .font(.footnote)
                                        .foregroundColor(Color(uiColor: .secondaryLabel))
                                }
                            })
                        }
                    }
                    .navigationBarTitle("Forms", displayMode: .inline)
                    .toolbar {
                        Button(action: {
                            showWordForms = false
                        }, label: {
                            Text("Dismiss")
                                .bold()
                        })
                    }
                }
            }
        }
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
        VStack {
            VStack {
                HStack {
                    Button(action: {
                        showWordInPassages = true
                    }, label: {
                        Image(systemName: "book")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    })
                    Spacer()
                    Button(action: {
                        showWordForms = true
                    }, label: {
                        Image(systemName: "filemenu.and.selection")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    })
                    Spacer()
                    Button(action: {
                        showWordInfo = true
                    }, label: {
                        Image(systemName: "info.circle")
                            .font(.title3)
                            .foregroundColor(.accentColor)
                    })
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 8)
            }
            .padding(.top, 4)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("Parsing:")
                            .font(.subheadline)
                            .foregroundColor(.init(uiColor: .secondaryLabel))
                        Text(currentInstance?.displayParsingStr ?? "")
                            .font(.headline)
                            .minimumScaleFactor(0.3)
                            .font(.title3)
                    }
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("Lexical form:")
                                .font(.subheadline)
                                .foregroundColor(.init(uiColor: .secondaryLabel))
                            Text(currentInstance?.lemma ?? "")
                                .font(.bible24)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Definition:")
                                .font(.subheadline)
                                .foregroundColor(.init(uiColor: .secondaryLabel))
                            Text(currentInstance?.wordInfo.definition ?? "")
                                .font(.headline)
                                .minimumScaleFactor(0.3)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
        .padding()
        .background(Color(UIColor.systemBackground))
        .foregroundColor(Color(uiColor: .label))
        .cornerRadius(Design.defaultCornerRadius)
        .padding(.horizontal)
    }
    
    func LemmaView() -> some View {
        Text(currentInstance?.textSurface ?? "")
            .font(.bible72)
            .lineLimit(1)
            .minimumScaleFactor(0.2)
            .frame(maxWidth: .infinity, maxHeight: 200)
            .padding(.horizontal)
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
                AnswerButton(answerType: .good, action: onCorrect)
                    .frame(maxWidth: .infinity)
                AnswerButton(answerType: .wrong, action: onWrong)
                    .frame(maxWidth: .infinity)
            }
        )
        .frame(minHeight: 100)
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
