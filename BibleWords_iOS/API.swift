//
//  WordList.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/22/22.
//

import Foundation
import CoreData

enum UserDefaultKey: String, CaseIterable {
    case hasFetchedAndSavedAllGreekWords
    case hasFetchedAndSavedAllHebrewWords
    case hasFetchedAndSavedModernGrammarHebrewGarret
    
    func get<T: Any>(as: T.Type) -> T {
        switch self {
        case .hasFetchedAndSavedAllGreekWords, .hasFetchedAndSavedAllHebrewWords, .hasFetchedAndSavedModernGrammarHebrewGarret:
            return UserDefaults.standard.bool(forKey: self.rawValue) as! T
        }
    }
    
    func set<T: Any>(val: T) {
        switch self {
        case .hasFetchedAndSavedAllGreekWords, .hasFetchedAndSavedAllHebrewWords, .hasFetchedAndSavedModernGrammarHebrewGarret:
            UserDefaults.standard.set(val, forKey: self.rawValue)
        }
    }
}

class API: ObservableObject {
    static let main = API()
    
    func fetchGreekBible() async {
        guard
            let data = await readLocalJSONFile(forName: "greek-bible"),
            let arrays = try? JSONSerialization.jsonObject(with: data, options: []) as? [[[[[String:AnyObject]]]]]
        else { return }
        
        Bible.main.references.values.append(contentsOf: arrays)
    }
    
    func fetchGreekDict() async {
        guard
            let data = await readLocalJSONFile(forName: "greek-dict"),
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject],
            let dict = json as? [String:[String:[String:AnyObject]]]
        else { return }
        
        Bible.main.greekLexicon = .init(lex: dict)
    }
    
    func fetchHebrewBible() async {
        guard
            let data = await readLocalJSONFile(forName: "hebrew-bible"),
            let arrays = try? JSONSerialization.jsonObject(with: data, options: []) as? [[[[[String:AnyObject]]]]]
        else { return }
        
        Bible.main.references = Bible.References(values: arrays)
    }
    
    func fetchHebrewDict() async {
        guard
            let data = await readLocalJSONFile(forName: "hebrew-dict"),
            let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:[String:[String:AnyObject]]]
        else { return }
        
        Bible.main.hebrewLexicon = .init(lex: dict)
    }

    private func readLocalJSONFile(forName name: String) async -> Data? {
        do {
            if let filePath = Bundle.main.path(forResource: name, ofType: "json") {
                let fileUrl = URL(fileURLWithPath: filePath)
                let data = try Data(contentsOf: fileUrl)
                return data
            }
        } catch {
            print("error: \(error)")
        }
        return nil
    }
    
    private func parse<T: Decodable>(jsonData: Data) async -> T? {
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: jsonData)
            return decodedData
        } catch {
            print("error: \(error)")
        }
        return nil
    }
    
//    private func saveIfNeeded(_ list: VocabWordListable, context: NSManagedObjectContext) {
//        
//        if let greekList = list as? CodeableGreekBibleVocabList {
//            guard UserDefaultKey.hasFetchedAndSavedAllGreekWords.get(as: Bool.self) == false else { return }
//            CoreDataManager.transaction(context: context) {
//                for word in greekList.words {
//                    _ = VocabWord.newGreek(for: context, word: word)
//                }
//            }
//            UserDefaultKey.hasFetchedAndSavedAllGreekWords.set(val: true)
//        } else if let hebrewList = list as? CodeableHebrewWordList {
//            guard UserDefaultKey.hasFetchedAndSavedAllHebrewWords.get(as: Bool.self) == false else { return }
//            CoreDataManager.transaction(context: context) {
//                for word in hebrewList.words {
//                    let newVocab = VocabWord.newHebrew(for: context, word: word)
//                    var sID = newVocab.gsid ?? ""
//                    sID = sID.replacingOccurrences(of: "H", with: "")
//                    if let count = StrongIDCount.main.dict[sID] {
//                        newVocab.occurenceCount = Int32(count)
//                    }
//                }
//            }
//            UserDefaultKey.hasFetchedAndSavedAllHebrewWords.set(val: true)
//        }
//    }

}
