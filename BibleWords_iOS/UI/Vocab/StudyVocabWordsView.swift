//
//  StudyVocabWordsView.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/23/22.
//

import SwiftUI
import CoreData
import ActivityKit

struct StudyVocabWordsView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @Namespace private var animation
    @State var vocabList: VocabWordList?
    @State var dueWordIds: [String] = []
    @State var newWordsIds: [String] = []
    @State var allWordInfoIds: [String] = []
    @State var displayMode = DisplayMode.lemma
    @State var interfaceMode: InterfaceMode = .normal
    @State var currentWord: VocabWord?
    @State var displayDef = ""
    @State var prevWord: VocabWord?
    @State var showWordDefView = false
    @State var showWordInfoView = false
    @State var showWordInPassageView = false
    
    @State var entries: [VocabStudySessionEntry] = []
    @State var startDate = Date()
    @State var endDate = Date()
    
    var isStudyingDueWords: Bool {
        return vocabList == nil
    }
    
    let buttonHeight: CGFloat = 60
    var onDismiss: (() -> Void)?
    
    var body: some View {
        NavigationView {
            ZStack {
//                Color(uiColor: .secondarySystemBackground)
//                    .ignoresSafeArea()
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
                        Text(vocabList?.title ?? "Due Words")
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
                VocabWordDefinitionView(vocabWord: currentWord!.bound()) { updatedWord in
                    currentWord = updatedWord
                    displayDef = currentWord?.definition ?? ""
                }
            })
            .sheet(isPresented: $showWordInfoView, content: {
                NavigationView {
                    WordInfoDetailsView(word: (currentWord?.wordInfo ?? .init([:])).bound(), isPresentedModally: true)
                }
            })
            .sheet(isPresented: $showWordInPassageView) {
                NavigationView {
                    List {
                        if (currentWord?.wordInfo.instances ?? []).isEmpty {
                            Text("Oops, it looks like this word was imported and does not have any associated bible passages. The developer will need to implement a feature to link custom words with words in the bible. Until then...")
                        } else {
                            Section {
                                Text(displayDef)
                            } header: {
                                Text("Definition")
                            }
                            Section {
                                ForEach(currentWord?.wordInfo.instances ?? []) { instance in
                                    NavigationLink(destination: {
                                        WordInstancePassageDetailsView(word: instance.wordInfo, instance: instance)
                                    }) {
                                        WordInstancePassageListRow(instance: instance)
                                    }
                                }
                            } header: {
                                if let instances = currentWord?.wordInfo.instances ?? [] {
                                    if instances.count == 1 {
                                        Text("1 Occurrence (Hapax Legomenon)")
                                    } else {
                                        Text("\(instances.count) Occurrences")
                                    }
                                }
                            }
                        }
                    }
                    .navigationBarTitle("", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text(currentWord?.wordInfo.lemma ?? "")
                                .font(currentWord?.wordInfo.language.meduimBibleFont ?? .bible32)
                        }
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: {
                                showWordInPassageView = false
                            }, label: {
                                Text("Dismiss")
                                    .bold()
                            })
                        }
                    }
                }
            }
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

extension StudyVocabWordsView {
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
            let entry = VocabStudySessionEntry.new(context: managedObjectContext, word: currentWord, prevInterval: (currentWord?.currentInterval ?? 0).toInt, interval: 1, newWord: true)
            entries.append(entry)
            
            currentWord?.currentInterval = 1
            currentWord?.dueDate = Date().addingTimeInterval(TimeInterval(15.seconds))
            updateCurrentWord()
        }
    }
    
    func onSkip() {
        CoreDataManager.transaction(context: managedObjectContext) {
            currentWord?.dueDate = Date().addingTimeInterval(TimeInterval(5.minutes))
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
            let studyAttributes = StudyAttributes(studyListName: vocabList?.defaultTitle ?? "Due Words")
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
        if isStudyingDueWords {
            dueWordIds = getDueWords().map { $0.id ?? "" }.filter { $0 != "" }
        } else {
            dueWordIds = vocabList?.dueWords.compactMap { $0.id }.filter { $0 != "" } ?? []
        }
        
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
                    newWord.sourceId = vocabList?.sources.first?.id ?? ""
                    currentWord = newWord
                    displayDef = currentWord?.definition ?? ""
                    vocabList?.addToWords(newWord)
                }
            } else {
                currentWord = matchingVocabIdDict[nextNewWordId]!
                displayDef = currentWord?.definition ?? ""
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
            displayDef = currentWord?.definition ?? ""
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
        displayDef = currentWord?.definition ?? ""
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
            session.activityTitle = vocabList?.title ?? "Due Words"
            session.activityTypeInt = ActivityType.vocab.rawValue
            
            for entry in entries {
                // add entries
                session.addToVocabEntries(entry)
            }
        }
        endLiveActivity()
        AppGroupManager.updateStats(managedObjectContext)
        presentationMode.wrappedValue.dismiss()
        onDismiss?()
    }
    
    func onWrong() {
        CoreDataManager.transaction(context: managedObjectContext) {
            let entry = VocabStudySessionEntry.new(context: managedObjectContext, word: currentWord, prevInterval: (currentWord?.currentInterval ?? 0).toInt, interval: 1)
            entries.append(entry)
            
            currentWord?.currentInterval = 1.toInt32
            let nextTime = VocabWord.defaultSRIntervals[1]
            currentWord?.dueDate = Date().addingTimeInterval(TimeInterval(nextTime))
            updateCurrentWord()
        }
    }
    
    func onCorrect() {
        guard let currentInterval = currentWord?.currentInterval else { return }
        var nextInterval = currentInterval.toInt
        if (currentInterval + 1) >= VocabWord.defaultSRIntervals.count {
            nextInterval = (VocabWord.defaultSRIntervals.count - 1)
        } else {
            nextInterval = (currentInterval + 1.toInt32).toInt
        }
        
        CoreDataManager.transaction(context: managedObjectContext) {
            let entry = VocabStudySessionEntry.new(context: managedObjectContext, word: currentWord, prevInterval: (currentWord?.currentInterval ?? 0).toInt, interval: nextInterval)
            entries.append(entry)
            
            currentWord?.currentInterval = nextInterval.toInt32
            let nextTime = VocabWord.defaultSRIntervals[Int(nextInterval)]
            currentWord?.dueDate = Date().addingTimeInterval(TimeInterval(nextTime))
            updateCurrentWord()
        }
    }
    
    func getDueWords() -> [VocabWord] {
        let vocabFetchRequest = NSFetchRequest<VocabWord>(entityName: "VocabWord")
        vocabFetchRequest.predicate = NSPredicate(format: "dueDate <= %@ && currentInterval > 0", Date() as CVarArg)
        var fetchedVocabWords: [VocabWord] = []
        do {
            fetchedVocabWords = try managedObjectContext.fetch(vocabFetchRequest)
        } catch let err {
            print(err)
        }
        
        return fetchedVocabWords.filter { ($0.list?.count ?? 0) > 0 }
    }
}

extension StudyVocabWordsView {
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
                .background(Color(uiColor: .secondarySystemBackground))
                .foregroundColor(Color(uiColor: .label))
                .cornerRadius(Design.defaultCornerRadius)
            HStack {
                if !(currentWord?.wordInfo.instances ?? []).isEmpty {
                    Button(action: {
                        showWordInPassageView = true
                    }, label: {
                        HStack {
                            Image(systemName: "book")
                                .font(.title2)
                            if (currentWord?.wordInfo.instances ?? []).count == 1 {
                                Text("Hapax Legomenon")
                            } else {
                                Text("\((currentWord?.wordInfo.instances ?? []).count)")
                                    .font(.subheadline)
                            }
                        }
                    })
                    .padding()
                }
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
                            Image(systemName: "gobackward")
                                .font(.title2)
                        })
                        .padding()
                    }
                    Spacer()
                    if displayMode != .learnWord {
                        Button(action: {
                            onSkip()
                        }, label: {
                            Image(systemName: "goforward")
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
        ZStack {
            Text(displayDef)
                .font(.system(size: 32))
                .minimumScaleFactor(0.3)
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: 225)
                .padding(.horizontal)
                .background(Color(uiColor: .secondarySystemBackground))
                .foregroundColor(Color(uiColor: .label))
                .cornerRadius(Design.defaultCornerRadius)
            if displayMode == .lemmaGloss || displayMode == .learnWord {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showWordDefView = true }, label: {
                            Image(systemName: "pencil.circle")
                                .font(.title2)
                        })
                        .padding()
                    }
                }
            }
        }
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
            HStack {
                answerType.buttonImage
                    .font(.largeTitle)
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
            VStack {
                AnswerButton(answerType: .good, detail: onGoodIntervalStr, action: onCorrect)
                AnswerButton(answerType: .wrong, detail: onWrongIntervalStr, action: onWrong)
                Menu(content: {
                    ForEach(0..<VocabWord.defaultSRIntervals.count, id: \.self) { i in
                        Button(action: {
                            CoreDataManager.transaction(context: managedObjectContext) {
                                let entry = VocabStudySessionEntry.new(context: managedObjectContext, word: currentWord, prevInterval: (currentWord?.currentInterval ?? 0).toInt, interval: i)
                                entries.append(entry)
                                
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
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .background(Color(uiColor: .systemGray))
                        .cornerRadius(Design.defaultCornerRadius)
                })
            }
        )
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
                FullLemmaGlossInteractionView()
            )
        }
    }
    
}
