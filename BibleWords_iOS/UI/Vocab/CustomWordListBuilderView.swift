//
//  CustomWordListBuilderView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 10/24/22.
//

import SwiftUI
import Combine

class CustomWordListBuilderViewModel: ObservableObject {
    @Published var list: VocabWordList?
    @Published var searchText = ""
    @Published var words: [Bible.WordInfo] = []
    @Published var loadedData = false
    @Published var isSearching = false
    private var subscriptions = Set<AnyCancellable>()
    
    init(list: Binding<VocabWordList>?) {
        self.list = list?.wrappedValue
    }
    
    func clearSearch() {
        self.words.removeAll()
    }
    
    func search() {
        var results: [Bible.WordInfo] = []
        
        DispatchQueue.global().async {
            results = Bible.main.greekLexicon.words()
                .filter {
                    $0.definition.lowercased().contains(self.searchText.lowercased()) ||
                    $0.id.lowercased().contains(self.searchText.lowercased()) ||
                    $0.lemma.strippingAccents.lowercased().contains(self.searchText.strippingAccents.lowercased())
                }
            results += Bible.main.hebrewLexicon.words()
                .filter {
                    $0.definition.lowercased().contains(self.searchText.lowercased()) ||
                    $0.id.lowercased().contains(self.searchText.lowercased()) ||
                    $0.lemma.strippingAccents.lowercased().contains(self.searchText.strippingAccents.lowercased()) ||
                    $0.lemma.strippingHebrewVowels.lowercased().contains(self.searchText.strippingAccents.lowercased())
                }
            results.sort {
                $0.lemma.lowercased().strippingAccents.strippingHebrewVowels <
                    $1.lemma.lowercased().strippingAccents.strippingHebrewVowels
            }
            
            DispatchQueue.main.async {
                self.words = results
                self.isSearching = false
            }
        }
    }
}

struct CustomWordListBuilderView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: CustomWordListBuilderViewModel
    var onFinishEditing: ((VocabWordList) -> Void)?
    
    @State var paths: [AppPath] = []
    @State var filterText = ""
    @State var selectedWords: [Bible.WordInfo] = []
    @State var listName = ""
    @State var listDetails = ""
    @State var showCustomWordForm = false
    @State var customLemma = ""
    @State var customDef = ""
    @State var linkedWordInfo: Bible.WordInfo?
    
    var canSave: Bool {
        return selectedWords.count > 0 && !listName.isEmpty
    }
    
    var body: some View {
        NavigationStack(path: $paths) {
            ZStack {
                List {
                    ListInfoSection()
                    SelectedWordInfosList()
                }
                SaveButton()
            }
            .sheet(isPresented: $showCustomWordForm) {
                CustomVocabWordForm()
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done", action: { hideKeyboard() })
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Cancel")
                            .fontWeight(.semibold)
                    })
                }
            }
            .onAppear {
                if viewModel.list != nil && viewModel.loadedData == false {
                    selectedWords = viewModel.list?.wordsArr.map { $0.wordInfo } ?? []
                    listName = viewModel.list?.title ?? ""
                    listDetails = viewModel.list?.details ?? ""
                    viewModel.loadedData = true
                }
            }
            .navigationDestination(for: AppPath.self) { path in
                switch path {
                case .selectedWords:
                    SeeSelectedWordsView()
                case .wordInfo(let word):
                    WordInfoDetailsView(word: word)
                case .wordInstance(let instance):
                    WordInPassageView(word: instance.wordInfo.bound(), instance: instance.bound())
                default:
                    Text("Route not active")
                }
            }
//            .navigationDestination(for: ViewPath.self) { path in
//                switch path {
//                case .seeList:
//                    SeeSelectedWordsView()
//                case .wordInfo(let word):
//                    WordInfoDetailsView(word: word)
//                case .wordInstance(let instance):
//                    WordInPassageView(word: instance.wordInfo.bound(), instance: instance.bound())
//                }
//            }
            .navigationTitle("Custom Word List Builder")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension CustomWordListBuilderView {
    
    @ViewBuilder
    func ListInfoSection() -> some View {
        Section {
            TextField("List Name", text: $listName)
            TextField("List Details", text: $listDetails)
        }
        Section {
            NavigationLink(value: AppPath.selectedWords) {
                Text("Edit Words")
            }
        }
    }
    
    @ViewBuilder
    func SelectedWordInfosList() -> some View {
        Section {
            ForEach(selectedWords) { word in
                NavigationLink(value: AppPath.wordInfo(word)) {
                    WordInfoRow(wordInfo: word.bound())
                }
                .swipeActions {
                    Button(action: {
                        withAnimation {
                            onDelete(word)
                        }
                    }, label: {
                        Text("Delete")
                    })
                    .tint(Color.red)
                }
            }
        } header: {
            Text("\(selectedWords.count) words")
        }
    }
    
    @ViewBuilder
    func SeeSelectedWordsView() -> some View {
        List {
            if selectedWords.isEmpty {
                Text("Use the search bar above to search for Hebrew or Greek words to add to your list. You can search for: lemmas, definitions, and strong IDs")
                    .multilineTextAlignment(.center)
            } else {
                ForEach(selectedWords) { word in
                    HStack {
                        WordInfoRow(wordInfo: word.bound())
                        Spacer()
                        Button(action: {
                            onTap(word)
                        }, label: {
                            if selectedWords.contains(word) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            } else {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.accentColor)
                            }
                        })
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search for a greek/hebrew word")
        .onChange(of: viewModel.searchText) { search in
            if search.isEmpty {
                viewModel.clearSearch()
            }
        }
        .onSubmit(of: .search) {
            viewModel.isSearching = true
            viewModel.search()
        }
        .overlay {
            SearchList()
        }
        .navigationTitle("Selected Words")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    func SaveButton() -> some View {
        VStack {
            Spacer()
            AppButton(text: "Save List") {
                onSave()
            }
            .disabled(!canSave)
            .padding([.horizontal, .bottom])
        }
    }
    
    @ViewBuilder
    func SearchList() -> some View {
        if !viewModel.words.isEmpty || viewModel.isSearching {
            List {
                if viewModel.isSearching {
                    DataLoadingRow(text: "Searching...")
                } else {
                    ForEach(viewModel.words) { word in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(word.lemma)
                                    .font(word.language.meduimBibleFont)
                                    .padding(.bottom, 4)
                                Text(word.definition)
                                    .font(.subheadline)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                                    .multilineTextAlignment(.leading)
                                Text(word.id)
                                    .font(.subheadline)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Button(action: {
                                onTap(word)
                            }, label: {
                                if selectedWords.contains(word) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                } else {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.accentColor)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func CustomVocabWordForm() -> some View {
        NavigationStack {
            List {
                Section {
                    TextField("lemma", text: $customLemma)
                    TextField("Definition", text: $customDef)
                } header: {
                    Text("New Word Details")
                }
                
                Section {
                    
                } header: {
                    Text("Link word for context")
                }
            }
            .navigationTitle("Create Custom Word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: {
                    showCustomWordForm = false
                }, label: {
                    Text("Cancel")
                        .bold()
                })
            }
        }
    }
}

extension CustomWordListBuilderView {
    func onTap(_ word: Bible.WordInfo) {
        if let index = selectedWords.firstIndex(of: word) {
            selectedWords.remove(at: index)
        } else {
            selectedWords.append(word)
        }
    }
    
    func onDelete(_ word: Bible.WordInfo) {
        if let index = selectedWords.firstIndex(of: word) {
            selectedWords.remove(at: index)
        }
    }
    
    func onSave() {
        // save list
        CoreDataManager.transaction(context: context) {
            var editingList: VocabWordList
            if viewModel.list == nil {
                editingList = VocabWordList(context: context)
                editingList.id = UUID().uuidString
                editingList.title = listName
                editingList.details = listDetails
                editingList.createdAt = Date()
            } else {
                viewModel.list?.wordsArr.forEach {
                    viewModel.list?.removeFromWords($0)
                }
                editingList = viewModel.list!
                editingList.title = listName
                editingList.details = listDetails
            }
            
            // save ranges
            for word in selectedWords {
                if let vocab = word.vocabWord(context: context) {
                    editingList.addToWords(vocab)
                } else {
                    let newVocab = VocabWord(context: context, id: word.id, lemma: word.lemma, def: word.definition, lang: word.language)
                    newVocab.sourceId = API.Source.Info.app.id
                    newVocab.currentInterval = 0
                    newVocab.dueDate = Date()
                    editingList.addToWords(newVocab)
                }
            }
            onFinishEditing?(editingList)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CustomWordListBuilderView_Previews: PreviewProvider {
    static var previews: some View {
        CustomWordListBuilderView(viewModel: .init(list: nil))
    }
}
