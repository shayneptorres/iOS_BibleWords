//
//  StudyVocabListView.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/23/22.
//

import SwiftUI
import CoreData
import ActivityKit

struct StudyVocabListView: View, Equatable {
    static func == (lhs: StudyVocabListView, rhs: StudyVocabListView) -> Bool {
        return (lhs.vocabList.id ?? "") == (rhs.vocabList.id ?? "")
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @Namespace private var animation
    @Binding var vocabList: VocabWordList
    @State var dueWordIds: [String] = []
    @State var newWordsIds: [String] = []
    @State var allWordInfoIds: [String] = []
    @State var displayMode = DisplayMode.lemma
    @State var interfaceMode: InterfaceMode = .normal
    @State var currentWord: VocabWord?
    @State var prevWord: VocabWord?
    @State var showWordDefView = false
    @State var showWordInfoView = false
    
    @State var entries: [StudySessionEntry] = []
    @State var startDate = Date()
    @State var endDate = Date()
    
    let buttonHeight: CGFloat = 60
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .secondarySystemBackground)
                    .ignoresSafeArea()
                VStack {
                    if verticalSizeClass == .regular && horizontalSizeClass == .compact {
                        CompactWidthView()
                    } else if verticalSizeClass == .compact && horizontalSizeClass == .regular {
                        RegularWidthView()
                    } else if verticalSizeClass == .compact && horizontalSizeClass == .compact {
                        RegularWidthView()
                    } else {
                        RegularWidthView()
                    }
                }
                .padding(.horizontal, Design.smallViewHorziontalPadding)
            }
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    VStack {
                        Text("Studying")
                            .font(.system(size: 17))
                        Text(vocabList.title ?? "")
                            .font(.system(size: 12))
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: onDone, label: {
                        Text("Done")
                            .bold()
                    })
                }
            }
            .sheet(isPresented: $showWordDefView, content: {
                VocabWordDefinitionView(vocabWord: currentWord!.bound())
            })
            .sheet(isPresented: $showWordInfoView, content: {
                NavigationStack {
                    WordInfoDetailsView(word: (currentWord?.wordInfo ?? .init([:])).bound())
                }
            })
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                startDate = Date()
                updateCurrentWord()
            }
        }
    }
    
    @ViewBuilder
    func CompactWidthView() -> some View {
        VStack {
            HeaderView()
            VStack {
                LemmaCardView()
                if displayMode == .lemmaGloss || displayMode == .learnWord {
                    DefinitionView()
                }
                Spacer()
                DynamicUserInteractionView()
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func RegularWidthView() -> some View {
        GeometryReader { proxy in
            if proxy.size.height > proxy.size.width {
                CompactWidthView()
            } else {
                HStack {
                    VStack {
                        HeaderView()
                        LemmaCardView()
                        if displayMode == .lemmaGloss || displayMode == .learnWord {
                            DefinitionView()
                        }
                        Spacer()
                    }
                    .frame(width: proxy.size.width * 0.60)
                    .frame(maxHeight: .infinity)
                    VStack {
                        DynamicUserInteractionView()
                    }
                    .frame(width: proxy.size.width * 0.4)
                    .frame(maxHeight: .infinity)
                }
            }
        }
    }
}

extension StudyVocabListView {
    enum DisplayMode: Int {
        case lemma
        case lemmaGloss
        case learnWord
    }
    
    enum InterfaceMode {
        case normal
        case rightHanded
        case leftHanded
    }
    
    var onWrongIntervalStr: String {
        return "\(VocabWord.defaultSRIntervals[wrongInterval].toShortPrettyTime)"
    }
    
    var onHardIntervalStr: String {
        return "\(VocabWord.defaultSRIntervals[hardInterval].toShortPrettyTime)"
    }
    
    var onGoodIntervalStr: String {
        return "\(VocabWord.defaultSRIntervals[nextInterval].toShortPrettyTime)"
    }
    
    var onEasyIntervalStr: String {
        return "\(VocabWord.defaultSRIntervals[easyInterval].toShortPrettyTime)"
    }
    
    var wrongInterval: Int {
        return 1
    }
    
    var hardInterval: Int {
        guard let currentInterval = currentWord?.currentInterval.toInt else { return 0 }
        if (currentInterval - 1) <= 0 {
            return currentInterval
        }
        return currentInterval - 1
    }
    
    var currInterval: Int {
        guard let currentInterval = currentWord?.currentInterval else { return 0 }
        return Int(currentInterval)
    }
    
    var nextInterval: Int {
        guard let currentInterval = currentWord?.currentInterval else { return 0 }
        if currentInterval == VocabWord.defaultSRIntervals.count - 1 {
            return Int(currentInterval)
        }
        return Int(currentInterval + 1)
    }
    
    var easyInterval: Int {
        guard let currentInterval = currentWord?.currentInterval else { return 0 }
        if (currentInterval + 2) >= VocabWord.defaultSRIntervals.count - 1 {
            return Int(VocabWord.defaultSRIntervals.count - 1)
        }
        return Int(currentInterval + 2)
    }
    
    var currIntervalString: String {
        guard let currentInterval = currentWord?.currentInterval else { return "?" }
        return "\(VocabWord.defaultSRIntervals[Int(currentInterval)].toPrettyTime)"
    }
    
    func onReveal() {
        guard !dueWordIds.isEmpty || !newWordsIds.isEmpty else {
            presentationMode.wrappedValue.dismiss()
            return
        }
        withAnimation {
            displayMode = .lemmaGloss
        }
        updateOrCreateLiveActivity()
    }
    
    func onLearn() {
        CoreDataManager.transaction(context: managedObjectContext) {
            let entry = StudySessionEntry.new(context: managedObjectContext, word: currentWord, answer: .wrong)
            entries.append(entry)
            
            currentWord?.currentInterval = 1
            currentWord?.dueDate = Date().addingTimeInterval(TimeInterval(15.seconds))
            updateCurrentWord()
        }
    }
    
    func onSkip() {
        CoreDataManager.transaction(context: managedObjectContext) {
            currentWord?.dueDate = Date().addingTimeInterval(TimeInterval(1.minutes))
            updateCurrentWord()
        }
    }
    
    func onSet(_ interface: InterfaceMode) {
        withAnimation {
            self.interfaceMode = interface
        }
    }
    
    func updateOrCreateLiveActivity() {
        if #available(iOS 16.1, *) {
            print("This code only runs on iOS 16.1 and up")
            let studyAttributes = StudyAttributes(studyListName: vocabList.defaultTitle)
            let studyAttState = StudyAttributes.StudyState(id: UUID().uuidString,
                                                           date: startDate,
                                                           text: currentWord?.lemma ?? "",
                                                           def: currentWord?.definition ?? "",
                                                           displayModeInt: displayMode.rawValue,
                                                           dueCount: dueWordIds.count,
                                                           newCount: newWordsIds.count)
            
            if LiveActivityMonitor.main.studyActivity == nil {
                LiveActivityMonitor.main.studyActivity = try? Activity<StudyAttributes>.request(attributes: studyAttributes, contentState: studyAttState)
            } else {
                Task {
                    await LiveActivityMonitor.main.studyActivity?.update(using: studyAttState)
                }
            }
        }
    }
    
    func endLiveActivity() {
        if #available(iOS 16.1, *) {
            if LiveActivityMonitor.main.studyActivity != nil {
                Task {
                    await LiveActivityMonitor.main.studyActivity?.end(dismissalPolicy: .immediate)
                    LiveActivityMonitor.main.studyActivity = nil
                }
            }
        }
    }

    func updateWords(vocabWordDict: [String:VocabWord]) {
        dueWordIds = vocabList.dueWords.compactMap { $0.id }.filter { $0 != "" }
        
        let allNewIds = Set(allWordInfoIds
            .filter {
                $0 != "" &&
                (
                    vocabWordDict[$0] == nil ||
                    vocabWordDict[$0]?.currentInterval == 0
                )
            })
        
        
        newWordsIds = Array(allNewIds)
    }
    
    func updateCurrentWord() {
        prevWord = currentWord
        
        if dueWordIds.count > 0 {
            dueWordIds.remove(at: 0)
        }
        
        let vocabFetchRequest = NSFetchRequest<VocabWord>(entityName: "VocabWord")
        vocabFetchRequest.predicate = NSPredicate(format: "SELF.id IN %@", allWordInfoIds)

        var matchingVocabWords: [VocabWord] = []
        do {
            matchingVocabWords = try managedObjectContext.fetch(vocabFetchRequest)
        } catch let err {
            print(err)
        }
        var matchingVocabIdDict: [String:VocabWord] = [:]
        matchingVocabWords.forEach { matchingVocabIdDict[$0.id ?? ""] = $0 }
        
        updateWords(vocabWordDict: matchingVocabIdDict)
        
        guard !dueWordIds.isEmpty || !newWordsIds.isEmpty else {
            onDone()
            return
        }
        
        if dueWordIds.isEmpty, let nextNewWordId = newWordsIds.first {
            if matchingVocabIdDict[nextNewWordId] == nil {
                CoreDataManager.transaction(context: managedObjectContext) {
                    let wordInfo = Bible.main.word(for: nextNewWordId)
                    let newWord = VocabWord(context: managedObjectContext,
                                            id: wordInfo?.id ?? "",
                                            lemma: wordInfo?.lemma ?? "",
                                            def: wordInfo?.definition ?? "",
                                            lang: wordInfo?.language ?? .greek)
                    newWord.sourceId = vocabList.sources.first?.id ?? ""
                    currentWord = newWord
                    vocabList.addToWords(newWord)
                }
            } else {
                currentWord = matchingVocabIdDict[nextNewWordId]!
            }
        } else if !dueWordIds.isEmpty {
            let vocabFetchRequest = NSFetchRequest<VocabWord>(entityName: "VocabWord")
            vocabFetchRequest.predicate = NSPredicate(format: "SELF.id == %@", dueWordIds.first!)

            var matchingVocabWords: [VocabWord] = []
            do {
                matchingVocabWords = try managedObjectContext.fetch(vocabFetchRequest)
            } catch let err {
                print(err)
            }
            currentWord = matchingVocabWords.first
        }

        if currentWord?.currentInterval == 0 {
            displayMode = .learnWord
        } else {
            displayMode = .lemma
        }
        updateOrCreateLiveActivity()
        UserDefaultKey.shouldRefreshWidgetTimeline.set(val: true)
    }
    
    func onPrev() {
        currentWord = prevWord
        prevWord = nil
        displayMode = .lemma
    }
    
    func onDone() {
        endDate = Date()
        
        // create session
        CoreDataManager.transactionAsync(context: managedObjectContext) {
            let session = StudySession(context: managedObjectContext)
            session.id = UUID().uuidString
            session.startDate = startDate
            session.endDate = endDate
            session.activityTitle = vocabList.title
            session.activityTypeInt = ActivityType.vocab.rawValue
            
            
            for entry in entries {
                // add entries
                session.addToEntries(entry)
            }
        }
        endLiveActivity()
        AppGroupManager.updateStats(managedObjectContext)
        presentationMode.wrappedValue.dismiss()
    }
    
    func onWrong() {
        CoreDataManager.transaction(context: managedObjectContext) {
            let entry = StudySessionEntry.new(context: managedObjectContext, word: currentWord, answer: .wrong)
            entries.append(entry)
            
            currentWord?.currentInterval = 1.toInt32
            let nextTime = VocabWord.defaultSRIntervals[1]
            currentWord?.dueDate = Date().addingTimeInterval(TimeInterval(nextTime))
            updateCurrentWord()
        }
    }
    
    func onHard() {
        guard (currentWord?.currentInterval) != nil else { return }
        let interval = hardInterval
        CoreDataManager.transaction(context: managedObjectContext) {
            let entry = StudySessionEntry.new(context: managedObjectContext, word: currentWord, answer: .hard)
            entries.append(entry)
            
            currentWord?.currentInterval = interval.toInt32
            let nextTime = VocabWord.defaultSRIntervals[interval]
            currentWord?.dueDate = Date().addingTimeInterval(TimeInterval(nextTime))
            updateCurrentWord()
        }
    }
    
    func onGood() {
        guard let currentInterval = currentWord?.currentInterval else { return }
        var nextInterval = currentInterval.toInt
        if (currentInterval + 1) >= VocabWord.defaultSRIntervals.count {
            nextInterval = (VocabWord.defaultSRIntervals.count - 1)
        } else {
            nextInterval = (currentInterval + 1.toInt32).toInt
        }
        
        CoreDataManager.transaction(context: managedObjectContext) {
            let entry = StudySessionEntry.new(context: managedObjectContext, word: currentWord, answer: .good)
            entries.append(entry)
            
            currentWord?.currentInterval = nextInterval.toInt32
            let nextTime = VocabWord.defaultSRIntervals[Int(nextInterval)]
            currentWord?.dueDate = Date().addingTimeInterval(TimeInterval(nextTime))
            updateCurrentWord()
        }
    }
    
    func onEasy() {
        guard let currentInterval = currentWord?.currentInterval else { return }
        var nextInterVal = currentInterval.toInt
        if currentInterval + 2 >= VocabWord.defaultSRIntervals.count {
            nextInterVal = VocabWord.defaultSRIntervals.count - 1
        } else {
            nextInterVal = (currentInterval + 2).toInt
        }
        
        CoreDataManager.transaction(context: managedObjectContext) {
            let entry = StudySessionEntry.new(context: managedObjectContext, word: currentWord, answer: .easy)
            entries.append(entry)
            
            currentWord?.currentInterval = nextInterVal.toInt32
            let nextTime = VocabWord.defaultSRIntervals[Int(nextInterVal)]
            currentWord?.dueDate = Date().addingTimeInterval(TimeInterval(nextTime))
            
            updateCurrentWord()
        }
    }
}

extension StudyVocabListView {
    func HeaderView() -> some View {
        HStack(alignment: .center) {
            Text("Words due: \(dueWordIds.count)")
                .font(.callout)
                .bold()
            Spacer()
            Text("New words: \(newWordsIds.count)")
                .font(.callout)
                .bold()
        }
        .foregroundColor(.white)
        .padding()
        .background(Color(uiColor: .systemGray))
        .cornerRadius(6)
        .padding(.top)
    }
    
    func LemmaCardView() -> some View {
        ZStack(alignment: .top) {
            Text(currentWord?.lemma ?? "")
                .padding(.vertical)
                .font(.bible100)
                .minimumScaleFactor(0.3)
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: 225)
                .padding(.horizontal)
                .background(Color(UIColor.systemBackground))
                .foregroundColor(Color(uiColor: .label))
                .cornerRadius(Design.defaultCornerRadius)
            HStack {
                Spacer()
                Button(action: {
                    showWordInfoView = true
                }, label: {
                    Image(systemName: "info.circle")
                        .font(.title2)
                })
                .padding()
            }
            VStack {
                Spacer()
                HStack {
                    if prevWord != nil {
                        Button(action: {
                            onPrev()
                        }, label: {
                            Image(systemName: "arrow.uturn.backward.circle")
                                .font(.title2)
                            Text("Previous word")
                                .font(.subheadline)
                        })
                        .padding()
                    }
                    Spacer()
                    if displayMode == .lemmaGloss || displayMode == .learnWord {
                        Button(action: { showWordDefView = true }, label: {
                            Image(systemName: "pencil.circle")
                                .font(.title2)
                        })
                        .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 225)
        }
    }
    
    func DefinitionView() -> some View {
        Text(currentWord?.definition ?? "")
            .font(.system(size: 32))
            .minimumScaleFactor(0.6)
            .padding(.top, 8)
    }
    
    func InterfaceButtonsView() -> some View {
        HStack {
            Button(action: { interfaceMode == .leftHanded ? onSet(.normal) : onSet(.leftHanded) }, label: {
                Image(systemName: interfaceMode == .leftHanded ? "keyboard.chevron.compact.down" : "keyboard.onehanded.left")
                    .frame(width: 30, height: 30)
            })
            Spacer()
            if displayMode == .lemmaGloss || displayMode == .learnWord {
                Button(action: { showWordDefView = true }, label: {
                    Image(systemName: "pencil.circle")
                        .frame(width: 30, height: 30)
                })
            }
            if displayMode == .lemmaGloss {
                Spacer()
                Button(action: onSkip, label: {
                    Image(systemName: "goforward.60")
                        .frame(width: 30, height: 30)
                })
            }
            Spacer()
            Button(action: { interfaceMode == .rightHanded ? onSet(.normal) : onSet(.rightHanded) }, label: {
                Image(systemName: interfaceMode == .rightHanded ? "keyboard.chevron.compact.down" : "keyboard.onehanded.right")
                    .frame(width: 30, height: 30)
            })
        }
    }
    
    func RevealBtnView() -> some View {
        return AnyView(
            HStack {
                Spacer()
                    .frame(maxWidth: interfaceMode == .rightHanded ? .infinity : 0)
                VStack {
                    InterfaceButtonsView()
                        .padding(.horizontal)
                    AppButton(text: "Reveal", height: interfaceMode == .normal ? 55 : 150, action: onReveal)
                        .frame(maxWidth: .infinity)
                        .animation(.easeInOut(duration: 0.2), value: interfaceMode)
                }
                Spacer()
                    .frame(maxWidth: interfaceMode == .leftHanded ? .infinity : 0)
            }
        )
    }
    
    func TapToRevealView() -> some View {
        return AnyView(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("Tap to Reveal")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.accentColor)
                    Spacer()
                }
                Spacer()
            }
                .background(Color.red.opacity(0.0001))
                .onTapGesture {
                    onReveal()
                }
        )
    }
    
    func LearnBtnView() -> some View {
        return AnyView(
            HStack {
                Spacer()
                    .frame(maxWidth: interfaceMode == .rightHanded ? .infinity : 0)
                VStack {
                    InterfaceButtonsView()
                        .padding(.horizontal)
                    AppButton(text: "Got it", height: interfaceMode == .normal ? 55 : 150, action: onLearn)
                        .frame(maxWidth: .infinity)
                        .animation(.easeInOut(duration: 0.2), value: interfaceMode)
                }
                Spacer()
                    .frame(maxWidth: interfaceMode == .leftHanded ? .infinity : 0)
            }
        )
    }
    
    func DynamicLemmaInteractionView() -> some View {
        TapToRevealView()
//        RevealBtnView()
    }
    
    func DynamicLearnInteractionView() -> some View {
        LearnBtnView()
    }
    
    func FullLearnInteractionView() -> some View {
        return AnyView(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack {
                        HStack {
                            Image(systemName: "gift.fill")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.accentColor)
                            Text("New Word!")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.accentColor)
                        }
                        Text("Tap anywhere to continue!")
                            .font(.headline)
                            .bold()
                            .foregroundColor(.accentColor)
                    }
                    Spacer()
                }
                Spacer()
            }
                .background(Color.red.opacity(0.0001))
                .onTapGesture {
                    onLearn()
                }
        )
    }
    
    func AnswerButton(answerType: SessionEntryAnswerType, detail: String, action: @escaping (() -> ())) -> some View {
        return Button(action: action, label: {
            VStack {
                answerType.buttonImage
                    .font(.largeTitle)
                    .padding(.bottom, 4)
                Text(detail)
                    .font(.subheadline)
                    .bold()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(answerType.color)
            .cornerRadius(Design.defaultCornerRadius)
        })
    }
    
    func FullLemmaGlossInteractionView() -> some View {
        return AnyView(
            HStack {
                VStack {
                    AnswerButton(answerType: .easy, detail: onEasyIntervalStr, action: onEasy)
                    Menu(content: {
                        ForEach(0..<VocabWord.defaultSRIntervals.count, id: \.self) { i in
                            Button(action: {
                                CoreDataManager.transaction(context: managedObjectContext) {
                                    currentWord?.currentInterval = i.toInt32
                                    let nextTime = VocabWord.defaultSRIntervals[Int(i)]
                                    currentWord?.dueDate = Date().addingTimeInterval(TimeInterval(nextTime))

                                    updateCurrentWord()
                                }
                            }, label: {
                                Text("\(VocabWord.defaultSRIntervals[i].toPrettyTime)").tag(i.toInt32)
                            })
                        }
                    }, label: {
                        Text("Set Interval")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(uiColor: .systemGray))
                            .cornerRadius(Design.defaultCornerRadius)
                    })
                    AnswerButton(answerType: .hard, detail: onHardIntervalStr, action: onHard)
                }
                .frame(maxWidth: .infinity)
                VStack {
                    AnswerButton(answerType: .good, detail: onGoodIntervalStr, action: onGood)
                    AnswerButton(answerType: .wrong, detail: onWrongIntervalStr, action: onWrong)
                }
                .frame(maxWidth: .infinity)
//                HStack {
//                    AnswerButton(answerType: .wrong, detail: onWrongIntervalStr, action: onWrong)
//                    AnswerButton(answerType: .hard, detail: onHardIntervalStr, action: onHard)
//                }
//                .frame(maxWidth: .infinity)
//                HStack {
//                    AnswerButton(answerType: .good, detail: onGoodIntervalStr, action: onGood)
//                    AnswerButton(answerType: .easy, detail: onEasyIntervalStr, action: onEasy)
//                }
//                .frame(maxWidth: .infinity)
//                Menu("Set Interval") {
//                    ForEach(0..<VocabWord.defaultSRIntervals.count, id: \.self) { i in
//                        Button(action: {
//                            CoreDataManager.transaction(context: managedObjectContext) {
//                                currentWord?.currentInterval = i.toInt32
//                                let nextTime = VocabWord.defaultSRIntervals[Int(i)]
//                                currentWord?.dueDate = Date().addingTimeInterval(TimeInterval(nextTime))
//
//                                updateCurrentWord()
//                            }
//                        }, label: {
//                            Text("\(VocabWord.defaultSRIntervals[i].toPrettyTime)").tag(i.toInt32)
//                        })
//                    }
//                }
//                .frame(height: 45)
            }
                .frame(maxWidth: .infinity)
        )
        .frame(minHeight: 100)
    }
    
    func DynamicLemmaGlossInteractionView() -> some View {
        if interfaceMode == .normal {
            return AnyView(
                VStack {
                    InterfaceButtonsView()
                    HStack {
                        AnswerButton(answerType: .wrong, detail: onWrongIntervalStr, action: onWrong)
                        AnswerButton(answerType: .hard, detail: onHardIntervalStr, action: onHard)
                        AnswerButton(answerType: .good, detail: onGoodIntervalStr, action: onGood)
                        AnswerButton(answerType: .easy, detail: onEasyIntervalStr, action: onEasy)
                    }
                    .frame(height: buttonHeight)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                }
            )

        } else {
            return AnyView(
                HStack {
                    Spacer()
                        .frame(maxWidth: interfaceMode == .rightHanded ? .infinity : 0)
                    VStack {
                        InterfaceButtonsView()
                        AnswerButton(answerType: .wrong, detail: onWrongIntervalStr, action: onWrong)
                            .frame(maxHeight: 60)
                        AnswerButton(answerType: .hard, detail: onHardIntervalStr, action: onHard)
                            .frame(maxHeight: 60)
                        AnswerButton(answerType: .good, detail: onGoodIntervalStr, action: onGood)
                            .frame(maxHeight: 60)
                        AnswerButton(answerType: .easy, detail: onEasyIntervalStr, action: onEasy)
                            .frame(maxHeight: 60)
                    }
                    Spacer()
                        .frame(maxWidth: interfaceMode == .leftHanded ? .infinity : 0)
                }
                    .animation(.easeInOut(duration: 0.2), value: interfaceMode)
            )
        }
    }
    
    func DynamicUserInteractionView() -> some View {
        if displayMode == .learnWord {
            return AnyView(
                FullLearnInteractionView()
            )
        } else if displayMode == .lemma {
            return AnyView(
                DynamicLemmaInteractionView()
            )
        } else {
            return AnyView(
//                DynamicLemmaGlossInteractionView()
                FullLemmaGlossInteractionView()
            )
        }
    }
    
}

//struct VocabListStudyView_Previews: PreviewProvider {
//    static var previews: some View {
//        StudyVocabListView(
//            vocabList: .constant(.simple(for: PersistenceController.preview.container.viewContext, lang: .greek)),
//            dueWords: [
//                .newGreek(for: PersistenceController.preview.container.viewContext),
//                .newGreek(for: PersistenceController.preview.container.viewContext),
//                .newGreek(for: PersistenceController.preview.container.viewContext)
//            ]
//        )
//    }
//}
