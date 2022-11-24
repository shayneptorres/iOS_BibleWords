//
//  ImportCSVView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/1/22.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftCSV
import CoreData

struct ImportCSVView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    @State var listName = ""
    @State var fileContent = ""
    @State var document: InputDoument = InputDoument(input: "")
    @State var importedWords: [ImportedWord] = []
    @State var showFilePicker = false
    
    var body: some View {
        NavigationView {
            List {
                TextField("List Name", text: $listName)
                Button(action: {
                    showFilePicker = true
                }, label: {
                    Label("Import File", systemImage: "arrow.down.doc")
                })
                
                if !importedWords.isEmpty {
                    Section {
                        ForEach(importedWords) { word in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(word.text)
                                    .font(.bible32)
                                Text(word.definition)
                                    .font(.footnote)
                                    .foregroundColor(Color(uiColor: .secondaryLabel))
                            }
                        }
                    } header: {
                        Text("\(importedWords.count) Imported Words")
                    }
                }
            }
            .navigationTitle("Import List from File")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Cancel").bold()
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        onSave()
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Save").bold()
                    })
                }
            }
            .fileImporter(isPresented: $showFilePicker,
                          allowedContentTypes: [.text],
                          allowsMultipleSelection: false,
                          onCompletion: { result in
                do {
                    guard let selectedFile: URL = try result.get().first else { return }
                    if selectedFile.startAccessingSecurityScopedResource() {
                        guard let input = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                        fileContent = input
                        handleCSV()
                    }
                    selectedFile.stopAccessingSecurityScopedResource()
                } catch {
                    // Handle failure.
                    print("Unable to read file contents")
                    print(error.localizedDescription)
                }
            })
        }
    }
    
    func handleCSV() {
        guard let csv = try? EnumeratedCSV(string: fileContent) else { return }
        for i in csv.rows {
            importedWords.append(.init(id: i[0], text: i[0], definition: i[1]))
        }
    }
    
    func onSave() {
        // save list
        CoreDataManager.transaction(context: context) {
            let importedList = VocabWordList(context: context)
            importedList.id = UUID().uuidString
            importedList.title = listName
            importedList.details = ""
            importedList.createdAt = Date()
            
            // save ranges
            for word in importedWords {
                if let vocab = word.vocabWord(context: context) {
                    importedList.addToWords(vocab)
                } else {
                    let newVocab = VocabWord(context: context, id: word.id, lemma: word.text, def: word.definition, lang: .custom)
                    newVocab.currentInterval = 0
                    newVocab.wordTypeInt = VocabWordType.userImported.rawValue
                    importedList.addToWords(newVocab)
                }
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ImportedWord: Identifiable {
    var id: String
    var text: String
    var definition: String
    var relatedWordInfoId: String = ""
    
    func vocabWord(context: NSManagedObjectContext) -> VocabWord? {
        let vocabFetchRequest = NSFetchRequest<VocabWord>(entityName: "VocabWord")
        vocabFetchRequest.predicate = NSPredicate(format: "SELF.id == %@", self.id)
        
        var word: VocabWord?
        do {
            word = try context.fetch(vocabFetchRequest).first
        } catch let err {
            print(err)
        }
        
        return word
    }
}

struct ImportCSVView_Previews: PreviewProvider {
    static var previews: some View {
        ImportCSVView()
    }
}

struct InputDoument: FileDocument {

    static var readableContentTypes: [UTType] { [.plainText] }

    var input: String

    init(input: String) {
        self.input = input
    }

    init(configuration: FileDocumentReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        input = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: input.data(using: .utf8)!)
    }

}
