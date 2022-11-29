//
//  VocabWordDefinitionView.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/29/22.
//

import SwiftUI

struct VocabWordDefinitionView: View {
    private enum Field: Int, Hashable {
        case definition
    }
    @FocusState private var focusedField: Field?
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Binding var vocabWord: VocabWord
    @State var customDefString = ""
    @State var useCustomDef = false
    @State var interval: Int32 = 1
    @State var onDismiss: ((VocabWord) -> Void)?
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading) {
                        Text("Lemma")
                            .font(.caption)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                            .padding(.bottom, 2)
                        Text(vocabWord.lemma)
                            .font(vocabWord.wordInfo.language.meduimBibleFont)
                    }
                    VStack(alignment: .leading) {
                        Text("Default definition")
                            .font(.caption)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                            .padding(.bottom, 2)
                        Text(vocabWord.wordInfo.definition)
                    }
                }
                Section(content: {
                    VStack(alignment: .leading) {
                        Text("Custom definition")
                            .font(.caption)
                            .foregroundColor(Color(uiColor: .secondaryLabel))
                            .padding(.bottom, 2)
                        TextEditor(text: $customDefString)
                            .focused($focusedField, equals: .definition)
                            .frame(height: 75)
                    }
                    Toggle(isOn: $useCustomDef, label: {
                        Text("Use this custom definition")
                    })
                }, header: {
                }, footer: {
                    Text("Add your own definition for this vocab word. This definition will be shown whenever this word is studied. You can switch back to the default definition at any time.")
                })
                
                Section {
                    Picker("Change Interval", selection: $interval) {
                        ForEach(0..<VocabWord.defaultSRIntervals.count, id: \.self) { i in
                            Text("\(VocabWord.defaultSRIntervals[i].toPrettyTime)").tag(i.toInt32)
                        }
                    }
                }
            }
            .toolbar {
                Button(action: onDone, label: { Text("Done").bold() })
            }
            .navigationTitle("Vocab Word Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            interval = vocabWord.currentInterval
            customDefString = vocabWord.customDefinition ?? ""
            if customDefString != "" {
                useCustomDef = true
            }
            focusedField = .definition
        }
        .interactiveDismissDisabled()
    }
    
    func onDone() {
        CoreDataManager.transaction(context: managedObjectContext) {
            if useCustomDef {
                vocabWord.customDefinition = customDefString
            } else {
                vocabWord.customDefinition = vocabWord.wordInfo.definition
            }
            vocabWord.currentInterval = interval
            onDismiss?(vocabWord)
        }
        presentationMode.wrappedValue.dismiss()
    }
}

//struct VocabWordDefinitionView_Previews: PreviewProvider {
//    static var previews: some View {
//        VocabWordDefinitionView(vocabWord: VocabWord.newGreek(for: PersistenceController.preview.container.viewContext).bound())
//    }
//}
