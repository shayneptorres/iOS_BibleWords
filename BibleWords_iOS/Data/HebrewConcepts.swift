//
//  HebrewConcepts.swift
//  BibleWords
//
//  Created by Shayne Torres on 9/25/22.
//

import Foundation

enum HebrewVerbalStem {
    case qal
    case niphal
    case hiphal
}

enum HebrewRoot {
    case strong
    case weak
}

enum HebrewParadigmType: Int, CaseIterable {
    case qatalStrong = 0
    case qatal3rdה
    case yiqtolStrong
    case yiqtol3rdה
    case constructSufformatives
    case pronominalSuffixesType1
    case pronominalSuffixesType2
    case qalActiveParticiple
    case qalActiveParticiple3rdה
    case qalPassiveParticiple
    case qalPassiveParticiple3rdה
    case demonstrativePronouns
    case subjectPronouns
    case directObjectPronouns
    case qalImperative
    case qalImperative3rdה

    var group: HebrewParadigmGroup {
        switch self {
        case .qatalStrong:
            return .init(title: "Qal Qatal", paradigms: [
                .init(text: "קָטַל", def: "He killed", person: .third, gender: .masculine, number: .singular),
                .init(text: "קָֽטְלוּ", def: "They (m) killed", person: .third, gender: .masculine, number: .plural),
                .init(text: "קָֽטְלָה", def: "She killed", person: .third, gender: .feminine, number: .singular),
                .init(text: "קָֽטְלוּ", def: "They (f) killed", person: .third, gender: .feminine, number: .plural),
                .init(text: "קָטַ֫לְתָּ", def: "You (m) killed", person: .second, gender: .masculine, number: .singular),
                .init(text: "קְטַלְתֶּם", def: "You all (m) killed", person: .second, gender: .masculine, number: .plural),
                .init(text: "קָטַלְתְּ", def: "You (f) killed", person: .second, gender: .feminine, number: .singular),
                .init(text: "קְטַלְתֶּן", def: "You all (f) killed", person: .second, gender: .feminine, number: .plural),
                .init(text: "קָטַ֫לְתִּי", def: "I killed", person: .first, gender: .common, number: .singular),
                .init(text: "קָטַ֫לְנוּ", def: "We killed", person: .first, gender: .common, number: .plural),
            ])
        case .qatal3rdה:
            return .init(title: "Qal Qatal (III-ה)", paradigms: [
                .init(text: "בָּנָה", def: "He built", person: .third, gender: .masculine, number: .singular),
                .init(text: "בָּנוּ", def: "They (m) built", person: .third, gender: .masculine, number: .plural),
                .init(text: "בָּֽנְתָה", def: "She built", person: .third, gender: .feminine, number: .singular),
                .init(text: "בָּנוּ", def: "They (f) built", person: .third, gender: .feminine, number: .plural),
                .init(text: "בָּנִ֫יתָ", def: "You (m) built", person: .second, gender: .masculine, number: .singular),
                .init(text: "בְּנִיתֶם", def: "You all (m) built", person: .second, gender: .masculine, number: .plural),
                .init(text: "בָּנִית", def: "You (f) built", person: .second, gender: .feminine, number: .singular),
                .init(text: "בְּנִיתֶן", def: "You all (f) built", person: .second, gender: .feminine, number: .plural),
                .init(text: "בָּנִ֫יתִי", def: "I built", person: .first, gender: .common, number: .singular),
                .init(text: "בָּנִ֫ינוּ", def: "We built", person: .first, gender: .common, number: .plural),
            ])
        case .yiqtolStrong:
            return .init(title: "Qal Yiqtol", paradigms: [
                .init(text: "יִקְטֹל", def: "He will kill", person: .third, gender: .masculine, number: .singular),
                .init(text: "יִקְטְלוּ", def: "They (m) will kill", person: .third, gender: .masculine, number: .plural),
                .init(text: "תִּקְטֹל", def: "She will kill", person: .third, gender: .feminine, number: .singular),
                .init(text: "תִּקְטֹ֫לְנָה", def: "They (f) will kill", person: .third, gender: .feminine, number: .plural),
                .init(text: "תִּקְטֹל", def: "You (m) will kill", person: .second, gender: .masculine, number: .singular),
                .init(text: "תִּקְטְלוּ", def: "You all (m) will kill", person: .second, gender: .masculine, number: .plural),
                .init(text: "תִּקְטְלִי", def: "You (f) will kill", person: .second, gender: .feminine, number: .singular),
                .init(text: "תִּקְטֹ֫לְנָה", def: "You all (f) will kill", person: .second, gender: .feminine, number: .plural),
                .init(text: "אֶקְטֹל", def: "I will kill", person: .first, gender: .common, number: .singular),
                .init(text: "נִקְטֹל", def: "We will kill", person: .first, gender: .common, number: .plural),
            ])
        case .yiqtol3rdה:
            return .init(title: "Qal Yiqtol (III-ה)", paradigms: [
                .init(text: "יִבְנֶה", def: "He will build", person: .third, gender: .masculine, number: .singular),
                .init(text: "יִבְנוּ", def: "They (m) will build", person: .third, gender: .masculine, number: .plural),
                .init(text: "תִּבְנֶה", def: "She will build", person: .third, gender: .feminine, number: .singular),
                .init(text: "תִּבְנֶ֫ינָה", def: "They (f) will build", person: .third, gender: .feminine, number: .plural),
                .init(text: "תִּבְנֶה", def: "You (m) will build", person: .second, gender: .masculine, number: .singular),
                .init(text: "תִּבְנוּ", def: "You all (m) will build", person: .second, gender: .masculine, number: .plural),
                .init(text: "תִּבְנִי", def: "You (f) will build", person: .second, gender: .feminine, number: .singular),
                .init(text: "תִּבְנֶ֫ינָה", def: "You all (f) will build", person: .second, gender: .feminine, number: .plural),
                .init(text: "אֶבְנֶה", def: "I will build", person: .first, gender: .common, number: .singular),
                .init(text: "נִבְנֶה", def: "We will build", person: .first, gender: .common, number: .plural),
            ])
        case .constructSufformatives:
            return .init(title: "Construct Sufformatives", paradigms: [
                .init(text: "סוּס", def: "The/a horse of", person: .none, gender: .masculine, number: .singular),
                .init(text: "סוּסַת", def: "The/a mare of", person: .none, gender: .feminine, number: .singular),
                .init(text: "סוּסֵי", def: "The horses of", person: .none, gender: .masculine, number: .plural),
                .init(text: "סוּסוֹת", def: "The mares of", person: .none, gender: .feminine, number: .plural),
            ])
        case .pronominalSuffixesType1:
            return .init(title: "Pronominal Suffixes (Type 1)", paradigms: [
                .init(text: "סוּסוֹ", def: "His horse", person: .third, gender: .masculine, number: .singular),
                .init(text: "סוּסָם", def: "Their (m) horse", person: .third, gender: .masculine, number: .plural),
                .init(text: "סוּסָהּ", def: "Her horse", person: .third, gender: .feminine, number: .singular),
                .init(text: "סוּסָן", def: "Their (f) horse", person: .third, gender: .feminine, number: .plural),
                .init(text: "סוּסְךָ", def: "Your (m) horse", person: .second, gender: .masculine, number: .singular),
                .init(text: "סוּסְכֶם", def: "Your (mp) horse", person: .second, gender: .masculine, number: .plural),
                .init(text: "סוּסֵךְ", def: "Your (f) horse", person: .second, gender: .feminine, number: .singular),
                .init(text: "סוּסְכֶן", def: "Your (fp) horse", person: .second, gender: .feminine, number: .plural),
                .init(text: "סוּסִי", def: "My horse", person: .first, gender: .common, number: .singular),
                .init(text: "סוּסֵ֫נוּ", def: "Our horse", person: .first, gender: .common, number: .plural),
            ])
        case .pronominalSuffixesType2:
            return .init(title: "Pronominal Suffixes (Type 2)", paradigms: [
                .init(text: "סוּסָיו", def: "His horses", person: .third, gender: .masculine, number: .singular),
                .init(text: "סוּסֵיהֶם", def: "Their (m) horses", person: .third, gender: .masculine, number: .plural),
                .init(text: "סוּסֶיהָ", def: "Her horses", person: .third, gender: .feminine, number: .singular),
                .init(text: "סוּסֵיהֶן", def: "Their (f) horses", person: .third, gender: .feminine, number: .plural),
                .init(text: "סוּסֶ֫יךָ", def: "Your (m) horses", person: .second, gender: .masculine, number: .singular),
                .init(text: "סוּסֵיכֶם", def: "Your (mp) horses", person: .second, gender: .masculine, number: .plural),
                .init(text: "סוּסַ֫יִךְ", def: "Your (f) horses", person: .second, gender: .feminine, number: .singular),
                .init(text: "סוּסֵיכֶן", def: "Your (fp) horses", person: .second, gender: .feminine, number: .plural),
                .init(text: "סוּסַי", def: "My horses", person: .first, gender: .common, number: .singular),
                .init(text: "סוּסֵ֫ינוּ", def: "Our horses", person: .first, gender: .common, number: .plural),
            ])
        case .qalActiveParticiple:
            return .init(title: "Qal Active Participle", paradigms: [
                .init(text: "קֹטֵל", def: "", person: .none, gender: .masculine, number: .singular),
                .init(text: "קֹטְלִים", def: "", person: .none, gender: .masculine, number: .plural),
                .init(text: "קֹטֶ֫לֶת", def: "", person: .none, gender: .feminine, number: .singular),
                .init(text: "קֹטְלוֹת", def: "", person: .none, gender: .feminine, number: .plural),
            ])
        case .qalActiveParticiple3rdה:
            return .init(title: "Qal Active Participle (III-ה)", paradigms: [
                .init(text: "בֹּנֶה", def: "", person: .none, gender: .masculine, number: .singular),
                .init(text: "בֹּנִים", def: "", person: .none, gender: .masculine, number: .plural),
                .init(text: "בֹּנָה", def: "", person: .none, gender: .feminine, number: .singular),
                .init(text: "בֹּנוֹת", def: "", person: .none, gender: .feminine, number: .plural),
            ])
        case .qalPassiveParticiple:
            return .init(title: "Qal Passive Participle", paradigms: [
                .init(text: "קָטוּל", def: "", person: .none, gender: .masculine, number: .singular),
                .init(text: "קְטוּלִים", def: "", person: .none, gender: .masculine, number: .plural),
                .init(text: "קְטוּלָה", def: "", person: .none, gender: .feminine, number: .singular),
                .init(text: "קְטוּלוֹת", def: "", person: .none, gender: .feminine, number: .plural),
            ])
        case .qalPassiveParticiple3rdה:
            return .init(title: "Qal Passive Participle (III-ה)", paradigms: [
                .init(text: "בָּנוּי", def: "", person: .none, gender: .masculine, number: .singular),
                .init(text: "בְּנוּיִם", def: "", person: .none, gender: .masculine, number: .plural),
                .init(text: "בְּנוּיָה", def: "", person: .none, gender: .feminine, number: .singular),
                .init(text: "בְּנוּיוֹת", def: "", person: .none, gender: .feminine, number: .plural),
            ])
        case .demonstrativePronouns:
            return .init(title: "Demonstrative Pronouns", paradigms: [
                .init(text: "זֶה", def: "This (m)", person: .none, gender: .masculine, number: .singular),
                .init(text: "הוּא", def: "That (m)", person: .none, gender: .masculine, number: .singular),
                .init(text: "זֹאת", def: "This (f)", person: .none, gender: .feminine, number: .singular),
                .init(text: "הִיא", def: "That (f)", person: .none, gender: .feminine, number: .singular),
                .init(text: "הַם", def: "Those (m)", person: .none, gender: .masculine, number: .plural),
                .init(text: "הֵ֫נָּה", def: "Those (f)", person: .none, gender: .feminine, number: .plural),
                .init(text: "אֵ֫לֶּה", def: "These (m/f)", person: .none, gender: .common, number: .plural),
            ])
        case .subjectPronouns:
            return .init(title: "Subject Pronouns", paradigms: [
                .init(text: "הוּא", def: "He", person: .third, gender: .masculine, number: .singular),
                .init(text: "הֵ֫מָּה / הֵם", def: "They (m)", person: .third, gender: .masculine, number: .plural),
                .init(text: "הִיא", def: "She", person: .third, gender: .feminine, number: .singular),
                .init(text: "הֵ֫נָּה", def: "They (f)", person: .third, gender: .feminine, number: .plural),
                .init(text: "אַתָּה", def: "You (m)", person: .second, gender: .masculine, number: .singular),
                .init(text: "אַתֶּם", def: "You all (m)", person: .second, gender: .masculine, number: .plural),
                .init(text: "אַתְּ", def: "You (f)", person: .second, gender: .feminine, number: .singular),
                .init(text: "אַתֵּ֫נָה / אַתֶּן", def: "You all (f)", person: .second, gender: .feminine, number: .plural),
                .init(text: "אֲנִי/אָנֹכִי", def: "I", person: .first, gender: .common, number: .singular),
                .init(text: "אֲנַ֫חְנוּ", def: "We", person: .first, gender: .common, number: .plural),
            ])

        case .directObjectPronouns:
            return .init(title: "Direct Object Pronouns", paradigms: [
                .init(text: "אֹתוֹ", def: "Him", person: .third, gender: .masculine, number: .singular),
                .init(text: "אֹתָם / אֶתְהֶם", def: "Them (m)", person: .third, gender: .masculine, number: .plural),
                .init(text: "אֹתָהּ", def: "Her", person: .third, gender: .feminine, number: .singular),
                .init(text: "אֹתָן / אֶתְהֶן", def: "Them (f)", person: .third, gender: .feminine, number: .plural),
                .init(text: "אֹתְךָ", def: "You (m)", person: .second, gender: .masculine, number: .singular),
                .init(text: "אֶתְכֶם", def: "You all (m)", person: .second, gender: .masculine, number: .plural),
                .init(text: "אֹתָךְ", def: "You (f)", person: .second, gender: .feminine, number: .singular),
                .init(text: "_", def: "Not extant", person: .second, gender: .feminine, number: .plural),
                .init(text: "אֹתִי", def: "Me", person: .first, gender: .common, number: .singular),
                .init(text: "אֹתָ֫נוּ", def: "Us", person: .first, gender: .common, number: .plural),
            ])
        case .qalImperative:
            return .init(title: "Qal Imperative", paradigms: [
                .init(text: "קְטֹל", def: "You (ms) kill (command)", person: .none, gender: .masculine, number: .singular),
                .init(text: "קִטְלוּ", def: "You (mp) kill (command)", person: .none, gender: .masculine, number: .plural),
                .init(text: "קִטְלִי", def: "You (fs) kill (command)", person: .none, gender: .feminine, number: .singular),
                .init(text: "קְטֹלְנָה", def: "You (mp) kill (command)", person: .none, gender: .feminine, number: .plural),
            ])
        case .qalImperative3rdה:
            return .init(title: "Qal Imperative (III-ה)", paradigms: [
                .init(text: "בְּנֵה", def: "You (ms) make (command)", person: .none, gender: .masculine, number: .singular),
                .init(text: "בְּנוּ", def: "You (mp) make (command)", person: .none, gender: .masculine, number: .plural),
                .init(text: "בְּנִי", def: "You (fs) make (command)", person: .none, gender: .feminine, number: .singular),
                .init(text: "בְּנֶינָה", def: "You (fp) make (command)", person: .none, gender: .feminine, number: .plural),
            ])
        }
    }
}

enum PersonType: CaseIterable {
    case none
    case first
    case second
    case third
    
    func title(_ type: TitleDisplayType) -> String {
        switch type {
        case .short: return self.shortTitle
        case .medium: return self.mediumTitle
        case .long: return self.longTitle
        }
    }
    
    var longTitle: String {
        switch self {
        case .none:
            return "N/A"
        case .first:
            return "First Person"
        case .second:
            return "Second Person"
        case .third:
            return "Third Person"
        }
    }
    
    var mediumTitle: String {
        switch self {
        case .none:
            return "N/A"
        case .first:
            return "1st"
        case .second:
            return "2nd"
        case .third:
            return "3rd"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .none:
            return ""
        case .first:
            return "1"
        case .second:
            return "2"
        case .third:
            return "3"
        }
    }
}

enum GenderType: CaseIterable {
    case masculine
    case feminine
    case common
    
    func title(_ type: TitleDisplayType) -> String {
        switch type {
        case .short: return self.shortTitle
        case .medium: return self.mediumTitle
        case .long: return self.longTitle
        }
    }
    
    var longTitle: String {
        switch self {
        case .masculine:
            return "Masculine"
        case .feminine:
            return "Feminine"
        case .common:
            return "Common"
        }
    }
    
    var mediumTitle: String {
        switch self {
        case .masculine:
            return "Masc"
        case .feminine:
            return "Fem"
        case .common:
            return "Com"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .masculine:
            return "M"
        case .feminine:
            return "F"
        case .common:
            return "C"
        }
    }
}

enum NumberType: CaseIterable {
    case singular
    case plural
    
    func title(_ type: TitleDisplayType) -> String {
        switch type {
        case .short: return self.shortTitle
        case .medium: return self.mediumTitle
        case .long: return self.longTitle
        }
    }
    
    var longTitle: String {
        switch self {
        case .singular:
            return "Singular"
        case .plural:
            return "Plural"
        }
    }
    
    var mediumTitle: String {
        switch self {
        case .singular:
            return "Sing"
        case .plural:
            return "Plur"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .singular:
            return "S"
        case .plural:
            return "P"
        }
    }
}

struct HebrewParadigmGroup: Identifiable {
    let id: String = UUID().uuidString
    let title: String
    let paradigms: [HebrewParadigm]
}

enum TitleDisplayType {
    case short
    case medium
    case long
}

struct HebrewParadigm: Identifiable {
    let id: String = UUID().uuidString
    let text: String
    let def: String
    let person: PersonType
    let gender: GenderType
    let number: NumberType
    
    func parsing(display: TitleDisplayType = .long) -> String {
        switch display {
        case .short:
            return "\(person.title(display))\(gender.title(display))\(number.title(display))"
        case .medium:
            return "\(person.title(display))\(gender.title(display))\(number.title(display))"
        case .long:
            return "\(person.title(display)) \(gender.title(display)) \(number.title(display))"
        }
    }
}
