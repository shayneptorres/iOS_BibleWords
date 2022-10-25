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

enum HebrewConceptGroup: Int, CaseIterable {
    case verbs
    case nouns
    case numbers
    
    var title: String {
        switch self {
        case .verbs:
            return "Verb Concepts"
        case .nouns:
            return "Noun Concepts"
        case .numbers:
            return "Number Concepts"
        }
    }
    
    var concepts: [HebrewConcept] {
        switch self {
        case .verbs:
            return [
                .qatalStrong,
                .qatal3rdה,
                .yiqtolStrong,
                .yiqtol3rdה,
                .qalActiveParticiple,
                .qalActiveParticiple3rdה,
                .qalPassiveParticiple,
                .qalPassiveParticiple3rdה,
                .qalImperative,
                .qalImperative3rdה,
                .principalParts
            ]
        case .nouns:
            return [
                .constructSufformatives,
                .pronominalSuffixesType1,
                .pronominalSuffixesType2,
                .demonstrativePronouns,
                .subjectPronouns,
                .directObjectPronouns
            ]
        case .numbers:
            return [
                .hebrewNumbers1_10,
                .hebrewNumbersAbsoluteConstruct1_10,
                .hebrewNumbers11_19,
                .hebrewNumbersTens,
                .hebrewNumbersBigNumbers,
                .hebrewOrdinalNumbers
            ]
        }
    }
}

enum HebrewConcept: Int, CaseIterable {
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
    case hebrewNumbers1_10
    case hebrewNumbersAbsoluteConstruct1_10
    case hebrewNumbers11_19
    case hebrewNumbersTens
    case hebrewNumbersBigNumbers
    case hebrewOrdinalNumbers
    case principalParts
    
    var group: LanguageConcept {
        switch self {
        case .qatalStrong:
            return .init(title: "Qal Qatal", items: [
                .init(text: "קָטַל", definition: "He killed", details: "Qal Qatal Third Person Masculine Singluar"),
                .init(text: "קָֽטְלוּ", definition: "They (m) killed", details: "Qal Qatal Third Person Masculine Plural"),
                .init(text: "קָֽטְלָה", definition: "She killed", details: "Qal Qatal Third Person Feminine Singular"),
                .init(text: "קָֽטְלוּ", definition: "They (f) killed", details: "Qal Qatal Third Person Feminine Plural"),
                .init(text: "קָטַ֫לְתָּ", definition: "You (m) killed", details: "Qal Qatal Second Person Masculine Singular"),
                .init(text: "קְטַלְתֶּם", definition: "You all (m) killed", details: "Qal Qatal Second Person Masculine Plural"),
                .init(text: "קָטַלְתְּ", definition: "You (f) killed", details: "Qal Qatal Second Person Feminine Singular"),
                .init(text: "קְטַלְתֶּן", definition: "You all (f) killed", details: "Qal Qatal Second Person Feminine Plural"),
                .init(text: "קָטַ֫לְתִּי", definition: "I killed", details: "Qal Qatal First Person Common Singular"),
                .init(text: "קָטַ֫לְנוּ", definition: "We killed", details: "Qal Qatal First Person Common Plural"),
            ])
        case .qatal3rdה:
            return .init(title: "Qal Qatal (III-ה)", items: [
                .init(text: "בָּנָה", definition: "He built", details: "Qal Qatal Third Person Masculine Singular"),
                .init(text: "בָּנוּ", definition: "They (m) built", details: "Qal Qatal Third Person Masculine Plural"),
                .init(text: "בָּֽנְתָה", definition: "She built", details: "Qal Qatal Third Person Feminine Singular"),
                .init(text: "בָּנוּ", definition: "They (f) built", details: "Qal Qatal Third Person Feminine Plural"),
                .init(text: "בָּנִ֫יתָ", definition: "You (m) built", details: "Qal Qatal Second Person Masculine Singular"),
                .init(text: "בְּנִיתֶם", definition: "You all (m) built", details: "Qal Qatal Second Person Masculine Plural"),
                .init(text: "בָּנִית", definition: "You (f) built", details: "Qal Qatal Second Person Feminine Singular"),
                .init(text: "בְּנִיתֶן", definition: "You all (f) built", details: "Qal Qatal Second Person Feminine Plural"),
                .init(text: "בָּנִ֫יתִי", definition: "I built", details: "Qal Qatal First Person Common Singular"),
                .init(text: "בָּנִ֫ינוּ", definition: "We built", details: "Qal Qatal First Person Common Plural"),
            ])
        case .yiqtolStrong:
            return .init(title: "Qal Yiqtol", items: [
                .init(text: "יִקְטֹל", definition: "He will kill", details: "Qal Yiqtol Third Person Masculine Singular"),
                .init(text: "יִקְטְלוּ", definition: "They (m) will kill", details: "Qal Yiqtol Third Person Masculine Plural"),
                .init(text: "תִּקְטֹל", definition: "She will kill", details: "Qal Yiqtol Third Person Feminine Singular"),
                .init(text: "תִּקְטֹ֫לְנָה", definition: "They (f) will kill", details: "Qal Yiqtol Third Person Feminine Plural"),
                .init(text: "תִּקְטֹל", definition: "You (m) will kill", details: "Qal Yiqtol Second Person Masculine Singular"),
                .init(text: "תִּקְטְלוּ", definition: "You all (m) will kill", details: "Qal Yiqtol Second Person Masculine Plural"),
                .init(text: "תִּקְטְלִי", definition: "You (f) will kill", details: "Qal Yiqtol Second Person Feminine Singular"),
                .init(text: "תִּקְטֹ֫לְנָה", definition: "You all (f) will kill", details: "Qal Yiqtol Second Person Feminine Plural"),
                .init(text: "אֶקְטֹל", definition: "I will kill", details: "Qal Yiqtol First Person Common Singular"),
                .init(text: "נִקְטֹל", definition: "We will kill", details: "Qal Yiqtol First Person Common Plural"),
            ])
        case .yiqtol3rdה:
            return .init(title: "Qal Yiqtol (III-ה)", items: [
                .init(text: "יִבְנֶה", definition: "He will build", details: "Qal Yiqtol Third Person Masculine Singular"),
                .init(text: "יִבְנוּ", definition: "They (m) will build", details: "Qal Yiqtol Third Person Masculine Plural"),
                .init(text: "תִּבְנֶה", definition: "She will build", details: "Qal Yiqtol Third Person Feminine Singular"),
                .init(text: "תִּבְנֶ֫ינָה", definition: "They (f) will build", details: "Qal Yiqtol Third Person Feminine Plural"),
                .init(text: "תִּבְנֶה", definition: "You (m) will build", details: "Qal Yiqtol Second Person Masculine Singular"),
                .init(text: "תִּבְנוּ", definition: "You all (m) will build", details: "Qal Yiqtol Second Person Masculine Plural"),
                .init(text: "תִּבְנִי", definition: "You (f) will build", details: "Qal Yiqtol Second Person Feminine Singular"),
                .init(text: "תִּבְנֶ֫ינָה", definition: "You all (f) will build", details: "Qal Yiqtol Second Person Feminine Plural"),
                .init(text: "אֶבְנֶה", definition: "I will build", details: "Qal Yiqtol First Person Common Singular"),
                .init(text: "נִבְנֶה", definition: "We will build", details: "Qal Yiqtol First Person Common Plural"),
            ])
        case .constructSufformatives:
            return .init(title: "Construct Sufformatives", items: [
                .init(text: "סוּס", definition: "The/a horse of", details: "Masculine Singular"),
                .init(text: "סוּסַת", definition: "The/a mare of", details: "Feminine Singular"),
                .init(text: "סוּסֵי", definition: "The horses of", details: "Masculine Plural"),
                .init(text: "סוּסוֹת", definition: "The mares of", details: "Feminine Plural"),
            ])
        case .pronominalSuffixesType1:
            return .init(title: "Pronominal Suffixes (Type 1)", items: [
                .init(text: "סוּסוֹ", definition: "His horse", details: "Third Person Masculine Singular"),
                .init(text: "סוּסָם", definition: "Their (m) horse", details: "Third Person Masculine Plural"),
                .init(text: "סוּסָהּ", definition: "Her horse", details: "Third Person Feminine Singular"),
                .init(text: "סוּסָן", definition: "Their (f) horse", details: "Third Person Feminine Plural"),
                .init(text: "סוּסְךָ", definition: "Your (m) horse", details: "Second Person Masculine Singular"),
                .init(text: "סוּסְכֶם", definition: "Your (mp) horse", details: "Second Person Masculine Plural"),
                .init(text: "סוּסֵךְ", definition: "Your (f) horse", details: "Second Person Feminine Singular"),
                .init(text: "סוּסְכֶן", definition: "Your (fp) horse", details: "Second Person Feminine Plural"),
                .init(text: "סוּסִי", definition: "My horse", details: "First Person Common Singular"),
                .init(text: "סוּסֵ֫נוּ", definition: "Our horse", details: "First Person Common Plural"),
            ])
        case .pronominalSuffixesType2:
            return .init(title: "Pronominal Suffixes (Type 2)", items: [
                .init(text: "סוּסָיו", definition: "His horses", details: "Third Person Masculine Singular"),
                .init(text: "סוּסֵיהֶם", definition: "Their (m) horses", details: "Third Person Masculine Plural"),
                .init(text: "סוּסֶיהָ", definition: "Her horses", details: "Third Person Feminine Singular"),
                .init(text: "סוּסֵיהֶן", definition: "Their (f) horses", details: "Third Person Feminine Plural"),
                .init(text: "סוּסֶ֫יךָ", definition: "Your (m) horses", details: "Second Person Masculine Singular"),
                .init(text: "סוּסֵיכֶם", definition: "Your (mp) horses", details: "Second Person Masculine Plural"),
                .init(text: "סוּסַ֫יִךְ", definition: "Your (f) horses", details: "Second Person Feminine Singular"),
                .init(text: "סוּסֵיכֶן", definition: "Your (fp) horses", details: "Second Person Feminine Plural"),
                .init(text: "סוּסַי", definition: "My horses", details: "First Person Common Singular"),
                .init(text: "סוּסֵ֫ינוּ", definition: "Our horses", details: "First Person Common Plural"),
            ])
        case .qalActiveParticiple:
            return .init(title: "Qal Active Participle", items: [
                .init(text: "קֹטֵל", definition: "", details: "Qal Active Participle Masculine Singular"),
                .init(text: "קֹטְלִים", definition: "", details: "Qal Active Participle Masculine Plural"),
                .init(text: "קֹטֶ֫לֶת", definition: "", details: "Qal Active Participle Feminine Singular"),
                .init(text: "קֹטְלוֹת", definition: "", details: "Qal Active Participle Feminine Plural"),
            ])
        case .qalActiveParticiple3rdה:
            return .init(title: "Qal Active Participle (III-ה)", items: [
                .init(text: "בֹּנֶה", definition: "", details: "Qal Active Participle Masculine Singular"),
                .init(text: "בֹּנִים", definition: "", details: "Qal Active Participle Masculine Plural"),
                .init(text: "בֹּנָה", definition: "", details: "Qal Active Participle Feminine Singular"),
                .init(text: "בֹּנוֹת", definition: "", details: "Qal Active Participle Feminine Plural"),
            ])
        case .qalPassiveParticiple:
            return .init(title: "Qal Passive Participle", items: [
                .init(text: "קָטוּל", definition: "", details: "Qal Passive Participle Masculine Singular"),
                .init(text: "קְטוּלִים", definition: "", details: "Qal Passive Participle Masculine Plural"),
                .init(text: "קְטוּלָה", definition: "", details: "Qal Passive Participle Feminine Singular"),
                .init(text: "קְטוּלוֹת", definition: "", details: "Qal Passive Participle Feminine Plural"),
            ])
        case .qalPassiveParticiple3rdה:
            return .init(title: "Qal Passive Participle (III-ה)", items: [
                .init(text: "בָּנוּי", definition: "", details: "Qal Passive Participle Masculine Singular"),
                .init(text: "בְּנוּיִם", definition: "", details: "Qal Passive Participle Masculine Plural"),
                .init(text: "בְּנוּיָה", definition: "", details: "Qal Passive Participle Feminine Singular"),
                .init(text: "בְּנוּיוֹת", definition: "", details: "Qal Passive Participle Feminine Plural"),
            ])
        case .demonstrativePronouns:
            return .init(title: "Demonstrative Pronouns", items: [
                .init(text: "זֶה", definition: "This (m)", details: "Near Demonstrative Masculine Singular"),
                .init(text: "הוּא", definition: "That (m)", details: "Far Demonstrative Masculine Singular"),
                .init(text: "זֹאת", definition: "This (f)", details: "Near Demonstrative Feminine Singular"),
                .init(text: "הִיא", definition: "That (f)", details: "Far Demonstrative Feminine Singular"),
                .init(text: "הַם", definition: "Those (m)", details: "Far Demonstrative Masculine Plural"),
                .init(text: "הֵ֫נָּה", definition: "Those (f)", details: "Far Demonstrative Feminine Plural"),
                .init(text: "אֵ֫לֶּה", definition: "These (m/f)", details: "Near Demonstrative Common Plural"),
            ])
        case .subjectPronouns:
            return .init(title: "Subject Pronouns", items: [
                .init(text: "הוּא", definition: "He", details: "Subject Pronoun Third Person Masculine Singular"),
                .init(text: "הֵ֫מָּה / הֵם", definition: "They (m)", details: "Subject Pronoun Third Person Masculine Plural"),
                .init(text: "הִיא", definition: "She", details: "Subject Pronoun Third Person Feminine Singular"),
                .init(text: "הֵ֫נָּה", definition: "They (f)", details: "Subject Pronoun Third Person Feminine Plural"),
                .init(text: "אַתָּה", definition: "You (m)", details: "Subject Pronoun Second Person Masculine Singular"),
                .init(text: "אַתֶּם", definition: "You all (m)", details: "Subject Pronoun Second Person Masculine Plural"),
                .init(text: "אַתְּ", definition: "You (f)", details: "Subject Pronoun Second Person Feminine Singular"),
                .init(text: "אַתֵּ֫נָה / אַתֶּן", definition: "You all (f)", details: "Subject Pronoun Second Person Feminine Plural"),
                .init(text: "אֲנִי/אָנֹכִי", definition: "I", details: "Subject Pronoun First Person Common Singular"),
                .init(text: "אֲנַ֫חְנוּ", definition: "We", details: "Subject Pronoun First Person Common Plural"),
            ])

        case .directObjectPronouns:
            return .init(title: "Direct Object Pronouns", items: [
                .init(text: "אֹתוֹ", definition: "Him", details: "Dir. Obj. Pronoun Third Person Masculine Singular"),
                .init(text: "אֹתָם / אֶתְהֶם", definition: "Them (m)", details: "Dir. Obj. Pronoun Third Person Masculine Plural"),
                .init(text: "אֹתָהּ", definition: "Her", details: "Dir. Obj. Pronoun Third Person Feminine Singular"),
                .init(text: "אֹתָן / אֶתְהֶן", definition: "Them (f)", details: "Dir. Obj. Pronoun Third Person Feminine Plural"),
                .init(text: "אֹתְךָ", definition: "You (m)", details: "Dir. Obj. Pronoun Second Person Masculine Singular"),
                .init(text: "אֶתְכֶם", definition: "You all (m)", details: "Dir. Obj. Pronoun Second Person Masculine Plural"),
                .init(text: "אֹתָךְ", definition: "You (f)", details: "Dir. Obj. Pronoun Second Person Feminine Singular"),
                .init(text: "_", definition: "Not extant", details: "Dir. Obj. Pronoun Second Person Feminine Plural"),
                .init(text: "אֹתִי", definition: "Me", details: "Dir. Obj. Pronoun First Person Common Singular"),
                .init(text: "אֹתָ֫נוּ", definition: "Us", details: "Dir. Obj. Pronoun First Person Common Plural"),
            ])
        case .qalImperative:
            return .init(title: "Qal Imperative", items: [
                .init(text: "קְטֹל", definition: "You (ms) kill (command)", details: "Qal Imperative Masculine Singular"),
                .init(text: "קִטְלוּ", definition: "You (mp) kill (command)", details: "Qal Imperative Masculine Plural"),
                .init(text: "קִטְלִי", definition: "You (fs) kill (command)", details: "Qal Imperative Feminine Singular"),
                .init(text: "קְטֹלְנָה", definition: "You (mp) kill (command)", details: "Qal Imperative Feminine Plural"),
            ])
        case .qalImperative3rdה:
            return .init(title: "Qal Imperative (III-ה)", items: [
                .init(text: "בְּנֵה", definition: "You (ms) make (command)", details: "Qal Imperative Masculine Singular"),
                .init(text: "בְּנוּ", definition: "You (mp) make (command)", details: "Qal Imperative Masculine Plural"),
                .init(text: "בְּנִי", definition: "You (fs) make (command)", details: "Qal Imperative Feminine Singular"),
                .init(text: "בְּנֶינָה", definition: "You (fp) make (command)", details: "Qal Imperative Feminine Plural"),
            ])
        case .hebrewNumbers1_10:
            return .init(title: "Hebrew Numbers (1-10)", items: [
                .init(text: "אֶחָד", definition: "One", details: "Masc. Abs"),
                .init(text: "שְׁנַ֫יִם", definition: "Two", details: ""),
                .init(text: "שָׁלֹשׁ", definition: "Three", details: ""),
                .init(text: "אַרְבַּע", definition: "Four", details: ""),
                .init(text: "חָמֵשׁ", definition: "Five", details: ""),
                .init(text: "שֵׁשׁ", definition: "Six", details: ""),
                .init(text: "שֶׁ֫בַע", definition: "Seven", details: ""),
                .init(text: "שְׁמֹנֶה", definition: "Eight", details: ""),
                .init(text: "תֵּ֫שַׁע", definition: "Nine", details: ""),
                .init(text: "עֶ֫שֶׂר", definition: "Ten", details: ""),
            ])
        case .hebrewNumbersAbsoluteConstruct1_10:
            return .init(title: "Hebrew Numbers (Absolute and Construct)", items: [
                .init(text: "אֶחָד", definition: "One", details: "Masc. Abs"),
                .init(text: "אַחַת", definition: "One", details: "Fem. Abs"),
                
                .init(text: "שְׁנַ֫יִם", definition: "Two", details: "Masc. Abs."),
                .init(text: "שְׁנֵי", definition: "Two", details: "Masc. Const."),
                .init(text: "שְׁתַּ֫יִם", definition: "Two", details: "Fem. Abs"),
                .init(text: "שְׁתֵּי", definition: "Two", details: "Fem. Const"),
                
                .init(text: "שָׁלֹשׁ", definition: "Three", details: "Masc. Abs."),
                .init(text: "שְׁלֹשׁ", definition: "Three", details: "Masc. Const."),
                .init(text: "שְׁלֹשָׁה", definition: "Three", details: "Fem. Abs."),
                .init(text: "שְׁלֹ֫שֶׁת", definition: "Three", details: "Fem. Const."),
                
                .init(text: "אַרְבַּע", definition: "Four", details: "Masc. Abs. & Const."),
                .init(text: "אַרְבָּעָה", definition: "Four", details: "Fem. Abs"),
                .init(text: "אַרְבַּ֫עַת", definition: "Four", details: "Fem. Const."),
                
                .init(text: "חָמֵשׁ", definition: "Five", details: "Masc. Abs"),
                .init(text: "חֲמֵשׁ", definition: "Five", details: "Masc. Const."),
                .init(text: "חֲמִשָּה", definition: "Five", details: "Fem. Abs"),
                .init(text: "חֲמֵ֫שֶׁת", definition: "Five", details: "Fem. Const."),
                
                .init(text: "שֵׁשׁ", definition: "Six", details: ""),
                .init(text: "שֵׁשׁ", definition: "Six", details: ""),
                .init(text: "שֵׁשׁ", definition: "Six", details: ""),
                .init(text: "שֵׁשׁ", definition: "Six", details: ""),
                
                .init(text: "שֶׁ֫בַע", definition: "Seven", details: "Masc. Abs"),
                .init(text: "שְׁבַע", definition: "Seven", details: "Masc. Const."),
                .init(text: "שִׁבְעָה", definition: "Seven", details: "Fem. Abs."),
                .init(text: "שִׁבְעַת", definition: "Seven", details: "Fem. Const."),
                
                .init(text: "שְׁמֹנֶה", definition: "Eight", details: "Masc. Abs & Const."),
                .init(text: "שְׁמֹנָה", definition: "Eight", details: "Fem. Abs."),
                .init(text: "שְׁמֹנַת", definition: "Eight", details: "Fem. Const."),
                
                .init(text: "תֵּ֫שַׁע", definition: "Nine", details: "Masc. Abs."),
                .init(text: "תְּשַׁע", definition: "Nine", details: "Masc. Const."),
                .init(text: "תִּשְׁעָה", definition: "Nine", details: "Fem. Abs."),
                .init(text: "תִּשְׁעַת", definition: "Nine", details: "Fem. Const."),
                
                .init(text: "עֶ֫שֶׂר", definition: "Ten", details: "Masc. Abs."),
                .init(text: "עֶשֶׂר", definition: "Ten", details: "Masc. Const."),
                .init(text: "עֲשָׂרָה", definition: "Ten", details: "Fem. Abs."),
                .init(text: "עֲשֶׂ֫רֶת", definition: "Ten", details: "Fem. Const."),
            ])
        case .hebrewNumbers11_19:
            return .init(title: "Hebrew Numbers (11-19)", items: [
                .init(text: "אַחַד עָשָׂר", definition: "Eleven", details: "with Masculine"),
                .init(text: "עַשְׁתֵּי עָשָׂר", definition: "Eleven (alternate)", details: "with Masculine"),
                
                .init(text: "שְׁנֵים עָשָׂר", definition: "Tweleve", details: "with Feminine"),
                .init(text: "שְׁנֵי עָשָׂר", definition: "Tweleve (alternate)", details: "with Feminine"),
                
                .init(text: "שְׁלֹשָׁה עָשָׂר", definition: "Thirteen", details: "with Masculine"),
                .init(text: "שְׁלֹשׁ עֶשְׂרֵה", definition: "Thirteen", details: "with Feminine"),
                
                .init(text: "אַרְבָּעָה עָשָׂר", definition: "Fourteen", details: "with Masculine"),
                .init(text: "אָרְבָּע עֶשְׂרֵה", definition: "Fourteen", details: "with Feminine"),
                
                .init(text: "חֲמִשָּׁה עָשָׂר", definition: "Fifteen", details: "with Masculine"),
                .init(text: "חֲמֵשׁ עֶשְׂרֵה", definition: "Fifteen", details: "with Feminine"),
                
                .init(text: "שִׁשָּׁה עָשָׂר", definition: "Sixteen", details: "with Masculine"),
                .init(text: "שֵׁשׁ עֶשְׂרֵה", definition: "Sixteen", details: "with Feminine"),
                
                .init(text: "שִׁבְעָה עָשָׂר", definition: "Seventeen", details: "with Masculine"),
                .init(text: "שְׁבַע אֶשְׂרֵה", definition: "Seventeen", details: "with Feminine"),
                
                .init(text: "שְׁמֹנָה עָשָׂר", definition: "Eighteen", details: "with Masculine"),
                .init(text: "שְׁמֹנֶה עֶשְׂרֵה", definition: "Eighteen", details: "with Feminine"),
                
                .init(text: "תִּשְׁעָה עָשָׂר", definition: "Nineteen", details: "with Masculine"),
                .init(text: "תְּשַׁע עֶשְׂרֵה", definition: "Nineteen", details: "with Feminine"),
            ])
        case .hebrewNumbersTens:
            return .init(title: "Hebrew Numbers (Tens)", items: [
                .init(text: "עֶשְׂרִים", definition: "Twenty", details: ""),
                .init(text: "שְׁלֹשִׁים", definition: "Thirty", details: ""),
                .init(text: "אַרְבָּעִים", definition: "Fourty", details: ""),
                .init(text: "חֲמִשִּׁים", definition: "Fifty", details: ""),
                .init(text: "שִׁשִּׁים", definition: "Sixty", details: ""),
                .init(text: "שִׁבְעִים", definition: "Seventy", details: ""),
                .init(text: "שְׁמֹנִים", definition: "Eighty", details: ""),
                .init(text: "תִּשְׁעִים", definition: "Ninety", details: "")
            ])
        case .hebrewNumbersBigNumbers:
            return .init(title: "Hebrew Numbers (Big Numbers)", items: [
                .init(text: "מֵאָה", definition: "100", details: ""),
                .init(text: "מָאתַ֫יִם", definition: "200", details: ""),
                .init(text: "שְׁלֹשׁ מֵאוֹת", definition: "300", details: ""),
                .init(text: "אַרְבַּע מֵאוֹת", definition: "400", details: ""),
                .init(text: "אֶ֫לֶף", definition: "1,000", details: ""),
                .init(text: "אַלְפַּ֫יִם", definition: "2,000", details: ""),
                .init(text: "שְׁלֹ֫שֶׁת אֲלָפִים", definition: "3,000", details: ""),
                .init(text: "אַרבַּ֫עַת אֲלָפִים", definition: "4,000", details: ""),
                .init(text: "רְבָבָה", definition: "10,000", details: ""),
                .init(text: "רִבּוֹתַ֫יִם", definition: "20,000", details: ""),
                .init(text: "שְׁלֹשׁ רִבּוֹת", definition: "30,000", details: ""),
                .init(text: "אַרְבָּע רִבּוֹת", definition: "40,000", details: ""),
                .init(text: "53,400", definition: "שְׁלֹשׁה וַחֲמִשִּׁים אֶ֫לֶף וְאַרְבַּע מֵאוֹת", details: ""),
                .init(text: "אַרְבָּע רִבּוֹת", definition: "40,000", details: ""),
            ])
        case .hebrewOrdinalNumbers:
            return .init(title: "Hebrew Ordinal Numbers", items: [
                .init(text: "רִאשׁוֹן", definition: "First", details: "Masculine"),
                .init(text: "רִשׁוֹנָה", definition: "First", details: "Feminine"),
                
                .init(text: "שֵׁנִי", definition: "Second", details: "Masculine"),
                .init(text: "שֵׁנִית", definition: "Second", details: "Feminine"),
                
                .init(text: "שְׁלִישִׁי", definition: "Third", details: "Masculine"),
                .init(text: "שְׁלִישִׁית", definition: "Third", details: "Feminine"),
                
                .init(text: "רְבִיעִי", definition: "Fourth", details: "Masculine"),
                .init(text: "רְבִיעִית", definition: "Fourth", details: "Feminine"),
                
                .init(text: "חֲמִישִׁי", definition: "Fifth", details: "Masculine"),
                .init(text: "חֲמִישִׁית", definition: "Fifth", details: "Feminine"),
                
                .init(text: "שִׁשִּׁי", definition: "Sixth", details: "Masculine"),
                .init(text: "שִׁשִּׁית", definition: "Sixth", details: "Feminine"),
                
                .init(text: "שְׁבִיעִי", definition: "Seventh", details: "Masculine"),
                .init(text: "שְׁבִיעִית", definition: "Seventh", details: "Feminine"),
                
                .init(text: "שְׁמִינִי", definition: "Eighth", details: "Masculine"),
                .init(text: "שְׁמִינִית", definition: "Eighth", details: "Feminine"),
                
                .init(text: "תְּשִׁיעִי", definition: "Ninth", details: "Masculine"),
                .init(text: "תְּשִׁיעִית", definition: "Ninth", details: "Feminine"),
                
                .init(text: "עֲשִׂירִי", definition: "Tenth", details: "Masculine"),
                .init(text: "עֲשִׂירִית", definition: "Tenth", details: "Feminine")
            ])
        case .principalParts:
            return .init(title: "Principal Parts", items: [
                .init(text: "קָטַל", definition: "To kill\nYiqtol: יִקְטֹל \nInf. Const: קְטֹל \nParticiple: קֹטֵל", details: "(Strong)"),
                .init(text: "בָּנָה", definition: "To make, do\nYiqtol: יִבְנֶה \nInf. Const: בְּנוֹת \nParticiple: בּוֹנֶה", details: "(III-ח)\n"),
                .init(text: "עָמַד", definition: "To stand\nYiqtol: יַעֲמֹד \nInf. Const: עֲמֹד \nParticiple: עֹמֵד", details: "(I-ע)\n"),
                .init(text: "בָּחַר", definition: "To choose\nYiqtol: יִבְחַר \nInf. Const: בְּחֹר \nParticiple: בֹּחֵר", details: "(II-Guttural)"),
                .init(text: "שָׁמַע", definition: "To hear, listen\nYiqtol: יִשְׁמַע \nInf. Const: שְׁמֹעַ \nParticiple: שֹׁמֵעַ", details: "(III-ח/ע)\n"),
                .init(text: "מָצָא", definition: "To find\nYiqtol: יִמְצָא \nInf. Const: מְצֹא \nParticiple: מֹצֵא", details: "(III-א)"),
                .init(text: "חָטָא", definition: "To sin\nYiqtol: יֶחֱטָא \nInf. Const: חֲטֹא \nParticiple: חוֹטֵא", details: "(I-ח + III-א)"),
                .init(text: "נָפַל", definition: "To fall\nYiqtol: יִפֹּל \nInf. Const: נְפֹל \nParticiple: נֹפֵל", details: "(I-נ)"),
                .init(text: "שָׁב", definition: "To return\nYiqtol: יָשׁוּב \nInf. Const: שׁוּב \nParticiple: שָׁב", details: "(I-י)"),
                .init(text: "סָבַב", definition: "To encircle/surround/go about\nYiqtol: יָסֹב \nInf. Const: סְבֹב \nParticiple: סֹבֵב", details: "(Geminate)"),
                .init(text: "יָשַׁב", definition: "To sit/dwell\nYiqtol: יֵשֵׁב,תֵּשֵׁב \nInf. Const: שֶׁבֶת \nParticiple: יֹשֵׁב", details: "(I-י)"),
                .init(text: "יָרַשׁ", definition: "To possess\nYiqtol: יִירַשׁ \nInf. Const: רֶשֶׁת \nParticiple: יוֹרֵשׁ", details: "(I-י)"),
                .init(text: "אָמַר", definition: "say\nYiqtol: יֹאמַר \nInf. Const: לֵאמֹר \nParticiple: אֹמֵר", details: "(I-א)"),
                .init(text: "אָהַב", definition: "to love\nYiqtol: יֶאֱהַב \nInf. Const: אַהֲבַת \nParticiple: אֹהֵב", details: "(I-א)"),
                
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

struct LanguageConcept: Identifiable {
    let id: String = UUID().uuidString
    let title: String
    let items: [Item]
    
    struct Item: Identifiable {
        let id: String = UUID().uuidString
        let text: String
        let definition: String
        let details: String
    }
}

enum TitleDisplayType {
    case short
    case medium
    case long
}

//struct HebrewParadigm: Identifiable {
//    let id: String = UUID().uuidString
//    let text: String
//    let def: String
//    let person: PersonType
//    let gender: GenderType
//    let number: NumberType
//    
//    func parsing(display: TitleDisplayType = .long) -> String {
//        switch display {
//        case .short:
//            return "\(person.title(display))\(gender.title(display))\(number.title(display))"
//        case .medium:
//            return "\(person.title(display))\(gender.title(display))\(number.title(display))"
//        case .long:
//            return "\(person.title(display)) \(gender.title(display)) \(number.title(display))"
//        }
//    }
//}
