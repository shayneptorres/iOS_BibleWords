//
//  BuildParsingListView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/18/22.
//

import SwiftUI
import Combine

struct BuildParsingListView: View {
    enum SettingSelection {
        case none
        case nounCases
        case tenses
        case stems
        case hebVerbTypes
        case voices
        case moods
        case persons
        case genders
        case numbers
        
        var sheetHeight: CGFloat {
            switch self {
            case .none: return 0.0
            case .nounCases: return 200
            case .tenses: return 200
            case .stems: return 425
            case .hebVerbTypes: return 275
            case .voices: return 200
            case .moods: return 200
            case .persons: return 100
            case .genders: return 200
            case .numbers: return 115
            }
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var context
    
    @State var parsingInfos: [Bible.ParsingInfo] = []
    @State var range = BibleRange(bookStart: 40, bookEnd: 66, chapStart: 1, chapEnd: 22, occurrencesTxt: "50")
    
    @State var wordType = Parsing.WordType.verb
    @State var language = VocabWord.Language.greek
    
    @State var showSettingSelector = false
    @State var showBuildParingInfos = false
    @State var isBuilding = false
    @State var selectorType = SettingSelection.none
    let gridItemLayout: [GridItem] = [.init(.flexible()), .init(.flexible()), .init(.flexible())]
    
    @State var cases: [Parsing.Greek.Case] = []
    @State var tenses: [Parsing.Greek.Tense] = []
    @State var stems: [Parsing.Hebrew.Stem] = []
    @State var verbTypes: [Parsing.Hebrew.VerbType] = []
    @State var voices: [Parsing.Greek.Voice] = []
    @State var moods: [Parsing.Greek.Mood] = []
    @State var persons: [Parsing.Person] = []
    @State var genders: [Parsing.Gender] = []
    @State var numbers: [Parsing.Number] = []
    
    var body: some View {
        List {
            Section {
                if language == .greek {
                    GreekSettingsSection()
                } else {
                    HebrewSettingsSection()
                }
            } header: {
                Text("Parsing Settings")
            }
            Section {
                BibleRangePickerView(range: $range)
            } header: {
                Text("Bible Range")
            }
            
            Button(action: onBuild, label: {
                if isBuilding {
                    HStack {
                        Label("Building...", systemImage: "hammer")
                        ProgressView()
                            .progressViewStyle(.automatic)
                    }
                } else {
                    Label("Build list", systemImage: "hammer")
                }
            }).disabled(isBuilding)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Done")
                        .bold()
                })
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done", action: { hideKeyboard() })
            }
        }
        .sheet(isPresented: .init(get: {selectorType != .none}, set: {_ in})) {
            SettingSelector()
                .onDisappear {
                    selectorType = .none
                }
                .presentationDetents([.height(selectorType.sheetHeight)])
        }
        .sheet(isPresented: $showBuildParingInfos) {
            BuiltParsingWordsView()
        }
        .navigationTitle("Build Parsing List")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension BuildParsingListView {
    func onBuild() {
        isBuilding = true
        DispatchQueue.global().async {
            var words: Set<Bible.WordInfo> = []
            
            VocabListBuilder.buildVocabList(bookStart: range.bookStart,
                                                 chapStart: range.chapStart,
                                                 bookEnd: range.bookEnd,
                                                 chapEnd: range.chapEnd,
                                            occurrences: range.occurrencesInt).forEach { words.insert($0) }
            
            DispatchQueue.main.async {
                parsingInfos = Array(words).map { $0.parsingInfo }
                isBuilding = false
                showBuildParingInfos = true
            }
        }
    }
    
    func onSave() {
        CoreDataManager.transaction(context: context) {
            let parsingList = ParsingList(context: context)
            parsingList.id = UUID().uuidString
            parsingList.title = range.title
            parsingList.details = range.details
            parsingList.createdAt = Date()
            
            let range = VocabWordRange(context: context)
            
        }
    }
}

extension BuildParsingListView {
    func BuiltParsingWordsView() -> some View {
        NavigationStack {
            ZStack {
                List {
                    HStack {
                        Text("\(parsingInfos.count)")
                            .bold()
                            .foregroundColor(.accentColor)
                        +
                        Text(" words")
                    }
                    HStack {
                        Text("\(parsingInfos.flatMap { $0.instances }.count)")
                            .bold()
                            .foregroundColor(.accentColor)
                        +
                        Text(" forms")
                    }
                    ForEach(parsingInfos) { info in
                        VStack(alignment: .leading) {
                            Text(info.lemma)
                                .font(.bible32)
                                .padding(.bottom, 4)
                            Text(info.definition)
                                .font(.subheadline)
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                            VStack(alignment: .leading) {
                                Text("Forms")
                                Text(info.instances.map { $0.surface }.joined(separator: ", "))
                                    .font(.subheadline)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Design.defaultCornerRadius))
                            .cornerRadius(Design.smallCornerRadius)
                            .padding()
                        }
                    }
                }
                VStack {
                    Spacer()
                    AppButton(text: "Save Parsing List") {
                        
                    }
                }
            }
            .toolbar {
                Button(action: {showBuildParingInfos = false}, label: {Text("Dismiss").bold()})
            }
        }
    }
    
    func GreekSettingsSection() -> some View {
        Section {
            LanguagePicker()
            WordTypePicker()
            if wordType == .verb {
                VerbTenseRow()
                VerbVoiceRow()
                VerbMoodRow()
                if wordType == .verb && moods.contains(.participle) {
                    NounCasesRow()
                    GenderRow()
                    NumberRow()
                } else {
                    PersonRow()
                    NumberRow()
                }
            }
            if wordType == .noun {
                NounCasesRow()
                GenderRow()
                NumberRow()
            }
        } header: {
            Text("Greek Parsing Settings")
        }
    }
    
    func HebrewSettingsSection() -> some View {
        Section {
            LanguagePicker()
            WordTypePicker()
            if wordType == .noun {
                GenderRow()
                PersonRow()
                NumberRow()
            }
            if wordType == .verb {
                VerbStemRow()
                VerbTypeRow()
                GenderRow()
                PersonRow()
                NumberRow()
            }
        } header: {
            Text("Greek Parsing Settings")
        }
    }
}

extension BuildParsingListView {
    func LanguagePicker() -> some View {
        Picker("Language", selection: $language) {
            ForEach([VocabWord.Language.greek, VocabWord.Language.hebrew], id: \.rawValue) { lang in
                Text(lang.title).tag(lang)
            }
        }.animation(.easeInOut, value: language)
    }
    
    func WordTypePicker() -> some View {
        Picker("Word Type", selection: $wordType) {
            ForEach(Parsing.WordType.allCases.dropLast(), id: \.rawValue) { type in
                Text(type.name).tag(type)
            }
        }.animation(.easeInOut, value: wordType)
    }
    
    func VerbTenseRow() -> some View {
        Button(action: {
            selectorType = .tenses
        }, label: {
            HStack {
                Text("Select Verb Tense")
                Spacer()
                Text(tenses.isEmpty ? "None selected" : tenses.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(tense: Parsing.Greek.Tense) {
        if let index = tenses.firstIndex(of: tense) {
            tenses.remove(at: index)
        } else {
            tenses.append(tense)
        }
    }
    
    func VerbVoiceRow() -> some View {
        Button(action: {
            selectorType = .voices
        }, label: {
            HStack {
                Text("Select Verb Voice")
                Spacer()
                Text(voices.isEmpty ? "None selected" : voices.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(voice: Parsing.Greek.Voice) {
        if let index = voices.firstIndex(of: voice) {
            voices.remove(at: index)
        } else {
            voices.append(voice)
        }
    }
    
    func VerbMoodRow() -> some View {
        Button(action: {
            selectorType = .moods
        }, label: {
            HStack {
                Text("Select Verb Mood")
                Spacer()
                Text(moods.isEmpty ? "None selected" : moods.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(mood: Parsing.Greek.Mood) {
        if let index = moods.firstIndex(of: mood) {
            moods.remove(at: index)
        } else {
            moods.append(mood)
        }
    }
    
    func VerbStemRow() -> some View {
        Button(action: {
            selectorType = .stems
        }, label: {
            HStack {
                Text("Select Verb Stem")
                Spacer()
                Text(stems.isEmpty ? "None selected" : stems.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(stem: Parsing.Hebrew.Stem) {
        if let index = stems.firstIndex(of: stem) {
            stems.remove(at: index)
        } else {
            stems.append(stem)
        }
    }
    
    func VerbTypeRow() -> some View {
        Button(action: {
            selectorType = .hebVerbTypes
        }, label: {
            HStack {
                Text("Select Verb Type")
                Spacer()
                Text(verbTypes.isEmpty ? "None selected" : verbTypes.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(verbType: Parsing.Hebrew.VerbType) {
        if let index = verbTypes.firstIndex(of: verbType) {
            verbTypes.remove(at: index)
        } else {
            verbTypes.append(verbType)
        }
    }
    
    func NounCasesRow() -> some View {
        Button(action: {
            selectorType = .nounCases
        }, label: {
            HStack {
                Text("Select Case")
                Spacer()
                Text(cases.isEmpty ? "None selected" : cases.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(caseType: Parsing.Greek.Case) {
        if let index = cases.firstIndex(of: caseType) {
            cases.remove(at: index)
        } else {
            cases.append(caseType)
        }
    }
    
    func PersonRow() -> some View {
        Button(action: {
            selectorType = .persons
        }, label: {
            HStack {
                Text("Select Person")
                Spacer()
                Text(persons.isEmpty ? "None selected" : persons.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(person: Parsing.Person) {
        if let index = persons.firstIndex(of: person) {
            persons.remove(at: index)
        } else {
            persons.append(person)
        }
    }
    
    func GenderRow() -> some View {
        Button(action: {
            selectorType = .genders
        }, label: {
            HStack {
                Text("Select Gender")
                Spacer()
                Text(genders.isEmpty ? "None selected" : genders.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(gender: Parsing.Gender) {
        if let index = genders.firstIndex(of: gender) {
            genders.remove(at: index)
        } else {
            genders.append(gender)
        }
    }
    
    func NumberRow() -> some View {
        Button(action: {
            selectorType = .numbers
        }, label: {
            HStack {
                Text("Select Number")
                Spacer()
                Text(numbers.isEmpty ? "None selected" : numbers.map { $0.rawValue }.joined(separator: ", "))
                    .font(.footnote)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
            }
        })
    }
    
    func onTap(number: Parsing.Number) {
        if let index = numbers.firstIndex(of: number) {
            numbers.remove(at: index)
        } else {
            numbers.append(number)
        }
    }
    
}

extension BuildParsingListView {
    func SettingSelector() -> some View {
        switch selectorType {
        case .tenses:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Greek.Tense.allCases, id: \.rawValue) { tense in
                        VStack {
                            Text(tense.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(tenses.contains(tense) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(tense: tense)
                        }
                    }
                }
                .padding(.horizontal)
            )
        case .voices:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Greek.Voice.allCases, id: \.rawValue) { voice in
                        VStack {
                            Text(voice.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(voices.contains(voice) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(voice: voice)
                        }
                    }
                }
                .padding(.horizontal)
            )
        case .moods:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Greek.Mood.allCases, id: \.rawValue) { mood in
                        VStack {
                            Text(mood.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(moods.contains(mood) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(mood: mood)
                        }
                    }
                }
                .padding(.horizontal)
            )
        case .stems:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Hebrew.Stem.allCases, id: \.rawValue) { stem in
                        VStack {
                            Text(stem.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(stems.contains(stem) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(stem: stem)
                        }
                    }
                }
                .padding(.horizontal)
            )
        case .hebVerbTypes:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Hebrew.VerbType.allCases, id: \.rawValue) { vType in
                        VStack {
                            Text(vType.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(verbTypes.contains(vType) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(verbType: vType)
                        }
                    }
                }
                .padding(.horizontal)
            )
        case .persons:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Person.allCases, id: \.rawValue) { person in
                        VStack {
                            Text(person.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(persons.contains(person) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(person: person)
                        }
                    }
                }
                .padding(.horizontal)
            )
        case .nounCases:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Greek.Case.allCases, id: \.rawValue) { caseType in
                        VStack {
                            Text(caseType.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(cases.contains(caseType) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(caseType: caseType)
                        }
                    }
                }
                .padding(.horizontal)
            )
        case .genders:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Gender.allCases, id: \.rawValue) { gender in
                        VStack {
                            Text(gender.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(genders.contains(gender) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(gender: gender)
                        }
                    }
                }
                .padding(.horizontal)
            )
        case .numbers:
            return AnyView(
                LazyVGrid(columns: gridItemLayout, spacing: 8) {
                    ForEach(Parsing.Number.allCases, id: \.rawValue) { number in
                        VStack {
                            Text(number.rawValue)
                                .frame(maxWidth: .infinity, minHeight: 45)
                                .padding(12)
                                .background(numbers.contains(number) ? Color.accentColor : Color(UIColor.quaternaryLabel))
                                .cornerRadius(Design.defaultCornerRadius)
                        }
                        .onTapGesture {
                            onTap(number: number)
                        }
                    }
                }
                .padding(.horizontal)
            )
        default:
            return AnyView(
                Text("TBD")
            )
        }
    }
}

struct BuildParsingListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BuildParsingListView()
        }
    }
}
