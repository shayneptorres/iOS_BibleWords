//
//  WordList.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/22/22.
//

import Foundation
import CoreData
import Combine

enum UserDefaultKey: String, CaseIterable {
    case hasFetchedAndSavedAllGreekWords
    case hasFetchedAndSavedAllHebrewWords
    case hasFetchedAndSavedModernGrammarHebrewGarret
    case shouldRefreshWidgetTimeline
    
    func get<T: Any>(as: T.Type) -> T {
        switch self {
        case .hasFetchedAndSavedAllGreekWords, .hasFetchedAndSavedAllHebrewWords, .hasFetchedAndSavedModernGrammarHebrewGarret, .shouldRefreshWidgetTimeline:
            return UserDefaults.standard.bool(forKey: self.rawValue) as! T
        }
    }
    
    func set<T: Any>(val: T) {
        switch self {
        case .hasFetchedAndSavedAllGreekWords, .hasFetchedAndSavedAllHebrewWords, .hasFetchedAndSavedModernGrammarHebrewGarret, .shouldRefreshWidgetTimeline:
            UserDefaults.standard.set(val, forKey: self.rawValue)
        }
    }
}

class API: ObservableObject {
    
    enum BuiltTextbook {
        case garretHebrew
    }
    
    static let main = API()
    var coreDataReadyPublisher = CurrentValueSubject<Bool, Never>(false)
    var builtTextbooks = CurrentValueSubject<[BuiltTextbook], Never>([])
    
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
        
        Bible.main.hebrewLexicon.add(newLex: dict, source: API.Source.Info.app.id)
    }
    
    func fetchGarretHebrew() async {
        guard
            let data = await readLocalJSONFile(forName: "garret-hebrew-1-21"),
            let list: [TextbookImportWord] = await parse(jsonData: data)
        else { return }
        
        Bible.main.hebrewLexicon.add(list: list, id: Source.Info.hebrewGarret.id)
        var built = builtTextbooks.value
        built.append(.garretHebrew)
        builtTextbooks.send(built)
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
}

extension API {
    struct Source {
        struct Info: Identifiable {
            let id: String
            let longName: String
            let shortName: String
            let details: String
            let chapCount: Int
            
            static func info(for id: String) -> Info? {
                return all.first(where: { $0.id == id })
            }
            
            static let all: [Info] = [
                .app,
                .hebrewGarret
            ]
            
            static let textbookInfos: [Info] = [
                .hebrewGarret
            ]
            
            static let app: Info = .init(id: "dc86985c-3dd5-11ed-a92f-4a45421fd684",
                                         longName: "Provided by the BibleWords App",
                                         shortName: "App Provided",
                                         details: "Exported from https://openscriptures.org and organized by creator of BibleWords App",
                                         chapCount: -1)
            
            static let hebrewGarret: Info = .init(id: "91e878a1-4d3f-40a4-8c12-6e9bdabbb4ae",
                                                  longName: "A Modern Grammar for Biblical Hebrew: Garret, DeRouchie",
                                                  shortName: "A Modern Gammar for Biblical Hebrew",
                                                  details: "A Modern Grammar for Biblical Hebrew is a complete revision of Duane Garrett’s respected 2002 release originally entitled A Modern Grammar for Classical Hebrew. In addition to the revisions and contributions from new coauthor Jason DeRouchie, the book now includes the answer key for an all-new companion workbook and an updated vocabulary list for second year Hebrew courses.",
                                                  chapCount: 21)
            
        }
    }
}
