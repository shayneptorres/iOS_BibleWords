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
    case qalStemVerbs
    case otherStemVerbs
    case nouns
    case numbers
    
    var title: String {
        switch self {
        case .qalStemVerbs:
            return "Qal Stem Verb Concepts"
        case .otherStemVerbs:
            return "Other Stem Verb Concepts"
        case .nouns:
            return "Noun Concepts"
        case .numbers:
            return "Number Concepts"
        }
    }
    
    var concepts: [HebrewConcept] {
        switch self {
        case .qalStemVerbs:
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
                .qalPrincipalParts
            ]
        case .otherStemVerbs:
            return [
                .niphalPrincipalParts,
                .pielPrincipalParts,
                .hiphilPrincipalParts,
                .pualPrincipalParts,
                .hophalPrincipalParts,
                .hithpaelPrincipalParts
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
    case qalPrincipalParts
    case niphalPrincipalParts
    case pielPrincipalParts
    case hiphilPrincipalParts
    case pualPrincipalParts
    case hophalPrincipalParts
    case hithpaelPrincipalParts
    
    var group: LanguageConcept {
        switch self {
        case .qatalStrong:
            return .init(title: "Qal Qatal", items: [
                .init(text: "קָטַל", definition: "He killed", parsing: "Qal Qatal Third Person Masculine Singluar", details: ""),
                .init(text: "קָֽטְלוּ", definition: "They (m) killed", parsing: "Qal Qatal Third Person Masculine Plural", details: ""),
                .init(text: "קָֽטְלָה", definition: "She killed", parsing: "Qal Qatal Third Person Feminine Singular", details: ""),
                .init(text: "קָֽטְלוּ", definition: "They (f) killed", parsing: "Qal Qatal Third Person Feminine Plural", details: ""),
                .init(text: "קָטַ֫לְתָּ", definition: "You (m) killed", parsing: "Qal Qatal Second Person Masculine Singular", details: ""),
                .init(text: "קְטַלְתֶּם", definition: "You all (m) killed", parsing: "Qal Qatal Second Person Masculine Plural", details: ""),
                .init(text: "קָטַלְתְּ", definition: "You (f) killed", parsing: "Qal Qatal Second Person Feminine Singular", details: ""),
                .init(text: "קְטַלְתֶּן", definition: "You all (f) killed", parsing: "Qal Qatal Second Person Feminine Plural", details: ""),
                .init(text: "קָטַ֫לְתִּי", definition: "I killed", parsing: "Qal Qatal First Person Common Singular", details: ""),
                .init(text: "קָטַ֫לְנוּ", definition: "We killed", parsing: "Qal Qatal First Person Common Plural", details: ""),
            ])
        case .qatal3rdה:
            return .init(title: "Qal Qatal (III-ה)", items: [
                .init(text: "בָּנָה", definition: "He built", parsing: "Qal Qatal Third Person Masculine Singular", details: ""),
                .init(text: "בָּנוּ", definition: "They (m) built", parsing: "Qal Qatal Third Person Masculine Plural", details: ""),
                .init(text: "בָּֽנְתָה", definition: "She built", parsing: "Qal Qatal Third Person Feminine Singular", details: ""),
                .init(text: "בָּנוּ", definition: "They (f) built", parsing: "Qal Qatal Third Person Feminine Plural", details: ""),
                .init(text: "בָּנִ֫יתָ", definition: "You (m) built", parsing: "Qal Qatal Second Person Masculine Singular", details: ""),
                .init(text: "בְּנִיתֶם", definition: "You all (m) built", parsing: "Qal Qatal Second Person Masculine Plural", details: ""),
                .init(text: "בָּנִית", definition: "You (f) built", parsing: "Qal Qatal Second Person Feminine Singular", details: ""),
                .init(text: "בְּנִיתֶן", definition: "You all (f) built", parsing: "Qal Qatal Second Person Feminine Plural", details: ""),
                .init(text: "בָּנִ֫יתִי", definition: "I built", parsing: "Qal Qatal First Person Common Singular", details: ""),
                .init(text: "בָּנִ֫ינוּ", definition: "We built", parsing: "Qal Qatal First Person Common Plural", details: ""),
            ])
        case .yiqtolStrong:
            return .init(title: "Qal Yiqtol", items: [
                .init(text: "יִקְטֹל", definition: "He will kill", parsing: "Qal Yiqtol Third Person Masculine Singular", details: ""),
                .init(text: "יִקְטְלוּ", definition: "They (m) will kill", parsing: "Qal Yiqtol Third Person Masculine Plural", details: ""),
                .init(text: "תִּקְטֹל", definition: "She will kill", parsing: "Qal Yiqtol Third Person Feminine Singular", details: ""),
                .init(text: "תִּקְטֹ֫לְנָה", definition: "They (f) will kill", parsing: "Qal Yiqtol Third Person Feminine Plural", details: ""),
                .init(text: "תִּקְטֹל", definition: "You (m) will kill", parsing: "Qal Yiqtol Second Person Masculine Singular", details: ""),
                .init(text: "תִּקְטְלוּ", definition: "You all (m) will kill", parsing: "Qal Yiqtol Second Person Masculine Plural", details: ""),
                .init(text: "תִּקְטְלִי", definition: "You (f) will kill", parsing: "Qal Yiqtol Second Person Feminine Singular", details: ""),
                .init(text: "תִּקְטֹ֫לְנָה", definition: "You all (f) will kill", parsing: "Qal Yiqtol Second Person Feminine Plural", details: ""),
                .init(text: "אֶקְטֹל", definition: "I will kill", parsing: "Qal Yiqtol First Person Common Singular", details: ""),
                .init(text: "נִקְטֹל", definition: "We will kill", parsing: "Qal Yiqtol First Person Common Plural", details: ""),
            ])
        case .yiqtol3rdה:
            return .init(title: "Qal Yiqtol (III-ה)", items: [
                .init(text: "יִבְנֶה", definition: "He will build", parsing: "Qal Yiqtol Third Person Masculine Singular", details: ""),
                .init(text: "יִבְנוּ", definition: "They (m) will build", parsing: "Qal Yiqtol Third Person Masculine Plural", details: ""),
                .init(text: "תִּבְנֶה", definition: "She will build", parsing: "Qal Yiqtol Third Person Feminine Singular", details: ""),
                .init(text: "תִּבְנֶ֫ינָה", definition: "They (f) will build", parsing: "Qal Yiqtol Third Person Feminine Plural", details: ""),
                .init(text: "תִּבְנֶה", definition: "You (m) will build", parsing: "Qal Yiqtol Second Person Masculine Singular", details: ""),
                .init(text: "תִּבְנוּ", definition: "You all (m) will build", parsing: "Qal Yiqtol Second Person Masculine Plural", details: ""),
                .init(text: "תִּבְנִי", definition: "You (f) will build", parsing: "Qal Yiqtol Second Person Feminine Singular", details: ""),
                .init(text: "תִּבְנֶ֫ינָה", definition: "You all (f) will build", parsing: "Qal Yiqtol Second Person Feminine Plural", details: ""),
                .init(text: "אֶבְנֶה", definition: "I will build", parsing: "Qal Yiqtol First Person Common Singular", details: ""),
                .init(text: "נִבְנֶה", definition: "We will build", parsing: "Qal Yiqtol First Person Common Plural", details: ""),
            ])
        case .constructSufformatives:
            return .init(title: "Construct Sufformatives", items: [
                .init(text: "סוּס", definition: "The/a horse of", parsing: "Masculine Singular", details: ""),
                .init(text: "סוּסַת", definition: "The/a mare of", parsing: "Feminine Singular", details: ""),
                .init(text: "סוּסֵי", definition: "The horses of", parsing: "Masculine Plural", details: ""),
                .init(text: "סוּסוֹת", definition: "The mares of", parsing: "Feminine Plural", details: ""),
            ])
        case .pronominalSuffixesType1:
            return .init(title: "Pronominal Suffixes (Type 1)", items: [
                .init(text: "סוּסוֹ", definition: "His horse", parsing: "Third Person Masculine Singular", details: ""),
                .init(text: "סוּסָם", definition: "Their (m) horse", parsing: "Third Person Masculine Plural", details: ""),
                .init(text: "סוּסָהּ", definition: "Her horse", parsing: "Third Person Feminine Singular", details: ""),
                .init(text: "סוּסָן", definition: "Their (f) horse", parsing: "Third Person Feminine Plural", details: ""),
                .init(text: "סוּסְךָ", definition: "Your (m) horse", parsing: "Second Person Masculine Singular", details: ""),
                .init(text: "סוּסְכֶם", definition: "Your (mp) horse", parsing: "Second Person Masculine Plural", details: ""),
                .init(text: "סוּסֵךְ", definition: "Your (f) horse", parsing: "Second Person Feminine Singular", details: ""),
                .init(text: "סוּסְכֶן", definition: "Your (fp) horse", parsing: "Second Person Feminine Plural", details: ""),
                .init(text: "סוּסִי", definition: "My horse", parsing: "First Person Common Singular", details: ""),
                .init(text: "סוּסֵ֫נוּ", definition: "Our horse", parsing: "First Person Common Plural", details: ""),
            ])
        case .pronominalSuffixesType2:
            return .init(title: "Pronominal Suffixes (Type 2)", items: [
                .init(text: "סוּסָיו", definition: "His horses", parsing: "Third Person Masculine Singular", details: ""),
                .init(text: "סוּסֵיהֶם", definition: "Their (m) horses", parsing: "Third Person Masculine Plural", details: ""),
                .init(text: "סוּסֶיהָ", definition: "Her horses", parsing: "Third Person Feminine Singular", details: ""),
                .init(text: "סוּסֵיהֶן", definition: "Their (f) horses", parsing: "Third Person Feminine Plural", details: ""),
                .init(text: "סוּסֶ֫יךָ", definition: "Your (m) horses", parsing: "Second Person Masculine Singular", details: ""),
                .init(text: "סוּסֵיכֶם", definition: "Your (mp) horses", parsing: "Second Person Masculine Plural", details: ""),
                .init(text: "סוּסַ֫יִךְ", definition: "Your (f) horses", parsing: "Second Person Feminine Singular", details: ""),
                .init(text: "סוּסֵיכֶן", definition: "Your (fp) horses", parsing: "Second Person Feminine Plural", details: ""),
                .init(text: "סוּסַי", definition: "My horses", parsing: "First Person Common Singular", details: ""),
                .init(text: "סוּסֵ֫ינוּ", definition: "Our horses", parsing: "First Person Common Plural", details: ""),
            ])
        case .qalActiveParticiple:
            return .init(title: "Qal Active Participle", items: [
                .init(text: "קֹטֵל", definition: "", parsing: "Qal Active Participle Masculine Singular", details: ""),
                .init(text: "קֹטְלִים", definition: "", parsing: "Qal Active Participle Masculine Plural", details: ""),
                .init(text: "קֹטֶ֫לֶת", definition: "", parsing: "Qal Active Participle Feminine Singular", details: ""),
                .init(text: "קֹטְלוֹת", definition: "", parsing: "Qal Active Participle Feminine Plural", details: ""),
            ])
        case .qalActiveParticiple3rdה:
            return .init(title: "Qal Active Participle (III-ה)", items: [
                .init(text: "בֹּנֶה", definition: "", parsing: "Qal Active Participle Masculine Singular", details: ""),
                .init(text: "בֹּנִים", definition: "", parsing: "Qal Active Participle Masculine Plural", details: ""),
                .init(text: "בֹּנָה", definition: "", parsing: "Qal Active Participle Feminine Singular", details: ""),
                .init(text: "בֹּנוֹת", definition: "", parsing: "Qal Active Participle Feminine Plural", details: ""),
            ])
        case .qalPassiveParticiple:
            return .init(title: "Qal Passive Participle", items: [
                .init(text: "קָטוּל", definition: "", parsing: "Qal Passive Participle Masculine Singular", details: ""),
                .init(text: "קְטוּלִים", definition: "", parsing: "Qal Passive Participle Masculine Plural", details: ""),
                .init(text: "קְטוּלָה", definition: "", parsing: "Qal Passive Participle Feminine Singular", details: ""),
                .init(text: "קְטוּלוֹת", definition: "", parsing: "Qal Passive Participle Feminine Plural", details: ""),
            ])
        case .qalPassiveParticiple3rdה:
            return .init(title: "Qal Passive Participle (III-ה)", items: [
                .init(text: "בָּנוּי", definition: "", parsing: "Qal Passive Participle Masculine Singular", details: ""),
                .init(text: "בְּנוּיִם", definition: "", parsing: "Qal Passive Participle Masculine Plural", details: ""),
                .init(text: "בְּנוּיָה", definition: "", parsing: "Qal Passive Participle Feminine Singular", details: ""),
                .init(text: "בְּנוּיוֹת", definition: "", parsing: "Qal Passive Participle Feminine Plural", details: ""),
            ])
        case .demonstrativePronouns:
            return .init(title: "Demonstrative Pronouns", items: [
                .init(text: "זֶה", definition: "This (m)", parsing: "Near Demonstrative Masculine Singular", details: ""),
                .init(text: "הוּא", definition: "That (m)", parsing: "Far Demonstrative Masculine Singular", details: ""),
                .init(text: "זֹאת", definition: "This (f)", parsing: "Near Demonstrative Feminine Singular", details: ""),
                .init(text: "הִיא", definition: "That (f)", parsing: "Far Demonstrative Feminine Singular", details: ""),
                .init(text: "הַם", definition: "Those (m)", parsing: "Far Demonstrative Masculine Plural", details: ""),
                .init(text: "הֵ֫נָּה", definition: "Those (f)", parsing: "Far Demonstrative Feminine Plural", details: ""),
                .init(text: "אֵ֫לֶּה", definition: "These (m/f)", parsing: "Near Demonstrative Common Plural", details: ""),
            ])
        case .subjectPronouns:
            return .init(title: "Subject Pronouns", items: [
                .init(text: "הוּא", definition: "He", parsing: "Subject Pronoun Third Person Masculine Singular", details: ""),
                .init(text: "הֵ֫מָּה / הֵם", definition: "They (m)", parsing: "Subject Pronoun Third Person Masculine Plural", details: ""),
                .init(text: "הִיא", definition: "She", parsing: "Subject Pronoun Third Person Feminine Singular", details: ""),
                .init(text: "הֵ֫נָּה", definition: "They (f)", parsing: "Subject Pronoun Third Person Feminine Plural", details: ""),
                .init(text: "אַתָּה", definition: "You (m)", parsing: "Subject Pronoun Second Person Masculine Singular", details: ""),
                .init(text: "אַתֶּם", definition: "You all (m)", parsing: "Subject Pronoun Second Person Masculine Plural", details: ""),
                .init(text: "אַתְּ", definition: "You (f)", parsing: "Subject Pronoun Second Person Feminine Singular", details: ""),
                .init(text: "אַתֵּ֫נָה / אַתֶּן", definition: "You all (f)", parsing: "Subject Pronoun Second Person Feminine Plural", details: ""),
                .init(text: "אֲנִי/אָנֹכִי", definition: "I", parsing: "Subject Pronoun First Person Common Singular", details: ""),
                .init(text: "אֲנַ֫חְנוּ", definition: "We", parsing: "Subject Pronoun First Person Common Plural", details: ""),
            ])

        case .directObjectPronouns:
            return .init(title: "Direct Object Pronouns", items: [
                .init(text: "אֹתוֹ", definition: "Him", parsing: "Dir. Obj. Pronoun Third Person Masculine Singular", details: ""),
                .init(text: "אֹתָם / אֶתְהֶם", definition: "Them (m)", parsing: "Dir. Obj. Pronoun Third Person Masculine Plural", details: ""),
                .init(text: "אֹתָהּ", definition: "Her", parsing: "Dir. Obj. Pronoun Third Person Feminine Singular", details: ""),
                .init(text: "אֹתָן / אֶתְהֶן", definition: "Them (f)", parsing: "Dir. Obj. Pronoun Third Person Feminine Plural", details: ""),
                .init(text: "אֹתְךָ", definition: "You (m)", parsing: "Dir. Obj. Pronoun Second Person Masculine Singular", details: ""),
                .init(text: "אֶתְכֶם", definition: "You all (m)", parsing: "Dir. Obj. Pronoun Second Person Masculine Plural", details: ""),
                .init(text: "אֹתָךְ", definition: "You (f)", parsing: "Dir. Obj. Pronoun Second Person Feminine Singular", details: ""),
                .init(text: "_", definition: "Not extant", parsing: "Dir. Obj. Pronoun Second Person Feminine Plural", details: ""),
                .init(text: "אֹתִי", definition: "Me", parsing: "Dir. Obj. Pronoun First Person Common Singular", details: ""),
                .init(text: "אֹתָ֫נוּ", definition: "Us", parsing: "Dir. Obj. Pronoun First Person Common Plural", details: ""),
            ])
        case .qalImperative:
            return .init(title: "Qal Imperative", items: [
                .init(text: "קְטֹל", definition: "You (ms) kill (command)", parsing: "Qal Imperative Masculine Singular", details: ""),
                .init(text: "קִטְלוּ", definition: "You (mp) kill (command)", parsing: "Qal Imperative Masculine Plural", details: ""),
                .init(text: "קִטְלִי", definition: "You (fs) kill (command)", parsing: "Qal Imperative Feminine Singular", details: ""),
                .init(text: "קְטֹלְנָה", definition: "You (mp) kill (command)", parsing: "Qal Imperative Feminine Plural", details: ""),
            ])
        case .qalImperative3rdה:
            return .init(title: "Qal Imperative (III-ה)", items: [
                .init(text: "בְּנֵה", definition: "You (ms) make (command)", parsing: "Qal Imperative Masculine Singular", details: ""),
                .init(text: "בְּנוּ", definition: "You (mp) make (command)", parsing: "Qal Imperative Masculine Plural", details: ""),
                .init(text: "בְּנִי", definition: "You (fs) make (command)", parsing: "Qal Imperative Feminine Singular", details: ""),
                .init(text: "בְּנֶינָה", definition: "You (fp) make (command)", parsing: "Qal Imperative Feminine Plural", details: ""),
            ])
        case .hebrewNumbers1_10:
            return .init(title: "Hebrew Numbers (1-10)", items: [
                .init(text: "אֶחָד", definition: "One", parsing: "Masc. Abs", details: ""),
                .init(text: "שְׁנַ֫יִם", definition: "Two", parsing: "", details: ""),
                .init(text: "שָׁלֹשׁ", definition: "Three", parsing: "", details: ""),
                .init(text: "אַרְבַּע", definition: "Four", parsing: "", details: ""),
                .init(text: "חָמֵשׁ", definition: "Five", parsing: "", details: ""),
                .init(text: "שֵׁשׁ", definition: "Six", parsing: "", details: ""),
                .init(text: "שֶׁ֫בַע", definition: "Seven", parsing: "", details: ""),
                .init(text: "שְׁמֹנֶה", definition: "Eight", parsing: "", details: ""),
                .init(text: "תֵּ֫שַׁע", definition: "Nine", parsing: "", details: ""),
                .init(text: "עֶ֫שֶׂר", definition: "Ten", parsing: "", details: ""),
            ])
        case .hebrewNumbersAbsoluteConstruct1_10:
            return .init(title: "Hebrew Numbers (Absolute and Construct)", items: [
                .init(text: "אֶחָד", definition: "One", parsing: "Masc. Abs", details: ""),
                .init(text: "אַחַת", definition: "One", parsing: "Fem. Abs", details: ""),
                
                .init(text: "שְׁנַ֫יִם", definition: "Two", parsing: "Masc. Abs.", details: ""),
                .init(text: "שְׁנֵי", definition: "Two", parsing: "Masc. Const.", details: ""),
                .init(text: "שְׁתַּ֫יִם", definition: "Two", parsing: "Fem. Abs", details: ""),
                .init(text: "שְׁתֵּי", definition: "Two", parsing: "Fem. Const", details: ""),
                
                .init(text: "שָׁלֹשׁ", definition: "Three", parsing: "Masc. Abs.", details: ""),
                .init(text: "שְׁלֹשׁ", definition: "Three", parsing: "Masc. Const.", details: ""),
                .init(text: "שְׁלֹשָׁה", definition: "Three", parsing: "Fem. Abs.", details: ""),
                .init(text: "שְׁלֹ֫שֶׁת", definition: "Three", parsing: "Fem. Const.", details: ""),
                
                .init(text: "אַרְבַּע", definition: "Four", parsing: "Masc. Abs. & Const.", details: ""),
                .init(text: "אַרְבָּעָה", definition: "Four", parsing: "Fem. Abs", details: ""),
                .init(text: "אַרְבַּ֫עַת", definition: "Four", parsing: "Fem. Const.", details: ""),
                
                .init(text: "חָמֵשׁ", definition: "Five", parsing: "Masc. Abs", details: ""),
                .init(text: "חֲמֵשׁ", definition: "Five", parsing: "Masc. Const.", details: ""),
                .init(text: "חֲמִשָּה", definition: "Five", parsing: "Fem. Abs", details: ""),
                .init(text: "חֲמֵ֫שֶׁת", definition: "Five", parsing: "Fem. Const.", details: ""),
                
                .init(text: "שֵׁשׁ", definition: "Six", parsing: "", details: ""),
                .init(text: "שֵׁשׁ", definition: "Six", parsing: "", details: ""),
                .init(text: "שֵׁשׁ", definition: "Six", parsing: "", details: ""),
                .init(text: "שֵׁשׁ", definition: "Six", parsing: "", details: ""),
                
                .init(text: "שֶׁ֫בַע", definition: "Seven", parsing: "Masc. Abs", details: ""),
                .init(text: "שְׁבַע", definition: "Seven", parsing: "Masc. Const.", details: ""),
                .init(text: "שִׁבְעָה", definition: "Seven", parsing: "Fem. Abs.", details: ""),
                .init(text: "שִׁבְעַת", definition: "Seven", parsing: "Fem. Const.", details: ""),
                
                .init(text: "שְׁמֹנֶה", definition: "Eight", parsing: "Masc. Abs & Const.", details: ""),
                .init(text: "שְׁמֹנָה", definition: "Eight", parsing: "Fem. Abs.", details: ""),
                .init(text: "שְׁמֹנַת", definition: "Eight", parsing: "Fem. Const.", details: ""),
                
                .init(text: "תֵּ֫שַׁע", definition: "Nine", parsing: "Masc. Abs.", details: ""),
                .init(text: "תְּשַׁע", definition: "Nine", parsing: "Masc. Const.", details: ""),
                .init(text: "תִּשְׁעָה", definition: "Nine", parsing: "Fem. Abs.", details: ""),
                .init(text: "תִּשְׁעַת", definition: "Nine", parsing: "Fem. Const.", details: ""),
                
                .init(text: "עֶ֫שֶׂר", definition: "Ten", parsing: "Masc. Abs.", details: ""),
                .init(text: "עֶשֶׂר", definition: "Ten", parsing: "Masc. Const.", details: ""),
                .init(text: "עֲשָׂרָה", definition: "Ten", parsing: "Fem. Abs.", details: ""),
                .init(text: "עֲשֶׂ֫רֶת", definition: "Ten", parsing: "Fem. Const.", details: ""),
            ])
        case .hebrewNumbers11_19:
            return .init(title: "Hebrew Numbers (11-19)", items: [
                .init(text: "אַחַד עָשָׂר", definition: "Eleven", parsing: "with Masculine", details: ""),
                .init(text: "עַשְׁתֵּי עָשָׂר", definition: "Eleven (alternate)", parsing: "with Masculine", details: ""),
                
                .init(text: "שְׁנֵים עָשָׂר", definition: "Tweleve", parsing: "with Feminine", details: ""),
                .init(text: "שְׁנֵי עָשָׂר", definition: "Tweleve (alternate)", parsing: "with Feminine", details: ""),
                
                .init(text: "שְׁלֹשָׁה עָשָׂר", definition: "Thirteen", parsing: "with Masculine", details: ""),
                .init(text: "שְׁלֹשׁ עֶשְׂרֵה", definition: "Thirteen", parsing: "with Feminine", details: ""),
                
                .init(text: "אַרְבָּעָה עָשָׂר", definition: "Fourteen", parsing: "with Masculine", details: ""),
                .init(text: "אָרְבָּע עֶשְׂרֵה", definition: "Fourteen", parsing: "with Feminine", details: ""),
                
                .init(text: "חֲמִשָּׁה עָשָׂר", definition: "Fifteen", parsing: "with Masculine", details: ""),
                .init(text: "חֲמֵשׁ עֶשְׂרֵה", definition: "Fifteen", parsing: "with Feminine", details: ""),
                
                .init(text: "שִׁשָּׁה עָשָׂר", definition: "Sixteen", parsing: "with Masculine", details: ""),
                .init(text: "שֵׁשׁ עֶשְׂרֵה", definition: "Sixteen", parsing: "with Feminine", details: ""),
                
                .init(text: "שִׁבְעָה עָשָׂר", definition: "Seventeen", parsing: "with Masculine", details: ""),
                .init(text: "שְׁבַע אֶשְׂרֵה", definition: "Seventeen", parsing: "with Feminine", details: ""),
                
                .init(text: "שְׁמֹנָה עָשָׂר", definition: "Eighteen", parsing: "with Masculine", details: ""),
                .init(text: "שְׁמֹנֶה עֶשְׂרֵה", definition: "Eighteen", parsing: "with Feminine", details: ""),
                
                .init(text: "תִּשְׁעָה עָשָׂר", definition: "Nineteen", parsing: "with Masculine", details: ""),
                .init(text: "תְּשַׁע עֶשְׂרֵה", definition: "Nineteen", parsing: "with Feminine", details: ""),
            ])
        case .hebrewNumbersTens:
            return .init(title: "Hebrew Numbers (Tens)", items: [
                .init(text: "עֶשְׂרִים", definition: "Twenty", parsing: "", details: ""),
                .init(text: "שְׁלֹשִׁים", definition: "Thirty", parsing: "", details: ""),
                .init(text: "אַרְבָּעִים", definition: "Fourty", parsing: "", details: ""),
                .init(text: "חֲמִשִּׁים", definition: "Fifty", parsing: "", details: ""),
                .init(text: "שִׁשִּׁים", definition: "Sixty", parsing: "", details: ""),
                .init(text: "שִׁבְעִים", definition: "Seventy", parsing: "", details: ""),
                .init(text: "שְׁמֹנִים", definition: "Eighty", parsing: "", details: ""),
                .init(text: "תִּשְׁעִים", definition: "Ninety", parsing: "", details: "")
            ])
        case .hebrewNumbersBigNumbers:
            return .init(title: "Hebrew Numbers (Big Numbers)", items: [
                .init(text: "מֵאָה", definition: "100", parsing: "", details: ""),
                .init(text: "מָאתַ֫יִם", definition: "200", parsing: "", details: ""),
                .init(text: "שְׁלֹשׁ מֵאוֹת", definition: "300", parsing: "", details: ""),
                .init(text: "אַרְבַּע מֵאוֹת", definition: "400", parsing: "", details: ""),
                .init(text: "אֶ֫לֶף", definition: "1,000", parsing: "", details: ""),
                .init(text: "אַלְפַּ֫יִם", definition: "2,000", parsing: "", details: ""),
                .init(text: "שְׁלֹ֫שֶׁת אֲלָפִים", definition: "3,000", parsing: "", details: ""),
                .init(text: "אַרבַּ֫עַת אֲלָפִים", definition: "4,000", parsing: "", details: ""),
                .init(text: "רְבָבָה", definition: "10,000", parsing: "", details: ""),
                .init(text: "רִבּוֹתַ֫יִם", definition: "20,000", parsing: "", details: ""),
                .init(text: "שְׁלֹשׁ רִבּוֹת", definition: "30,000", parsing: "", details: ""),
                .init(text: "אַרְבָּע רִבּוֹת", definition: "40,000", parsing: "", details: ""),
                .init(text: "53,400", definition: "שְׁלֹשׁה וַחֲמִשִּׁים אֶ֫לֶף וְאַרְבַּע מֵאוֹת", parsing: "", details: ""),
                .init(text: "אַרְבָּע רִבּוֹת", definition: "40,000", parsing: "", details: ""),
            ])
        case .hebrewOrdinalNumbers:
            return .init(title: "Hebrew Ordinal Numbers", items: [
                .init(text: "רִאשׁוֹן", definition: "First", parsing: "Masculine", details: ""),
                .init(text: "רִשׁוֹנָה", definition: "First", parsing: "Feminine", details: ""),
                
                .init(text: "שֵׁנִי", definition: "Second", parsing: "Masculine", details: ""),
                .init(text: "שֵׁנִית", definition: "Second", parsing: "Feminine", details: ""),
                
                .init(text: "שְׁלִישִׁי", definition: "Third", parsing: "Masculine", details: ""),
                .init(text: "שְׁלִישִׁית", definition: "Third", parsing: "Feminine", details: ""),
                
                .init(text: "רְבִיעִי", definition: "Fourth", parsing: "Masculine", details: ""),
                .init(text: "רְבִיעִית", definition: "Fourth", parsing: "Feminine", details: ""),
                
                .init(text: "חֲמִישִׁי", definition: "Fifth", parsing: "Masculine", details: ""),
                .init(text: "חֲמִישִׁית", definition: "Fifth", parsing: "Feminine", details: ""),
                
                .init(text: "שִׁשִּׁי", definition: "Sixth", parsing: "Masculine", details: ""),
                .init(text: "שִׁשִּׁית", definition: "Sixth", parsing: "Feminine", details: ""),
                
                .init(text: "שְׁבִיעִי", definition: "Seventh", parsing: "Masculine", details: ""),
                .init(text: "שְׁבִיעִית", definition: "Seventh", parsing: "Feminine", details: ""),
                
                .init(text: "שְׁמִינִי", definition: "Eighth", parsing: "Masculine", details: ""),
                .init(text: "שְׁמִינִית", definition: "Eighth", parsing: "Feminine", details: ""),
                
                .init(text: "תְּשִׁיעִי", definition: "Ninth", parsing: "Masculine", details: ""),
                .init(text: "תְּשִׁיעִית", definition: "Ninth", parsing: "Feminine", details: ""),
                
                .init(text: "עֲשִׂירִי", definition: "Tenth", parsing: "Masculine", details: ""),
                .init(text: "עֲשִׂירִית", definition: "Tenth", parsing: "Feminine", details: "")
            ])
        case .qalPrincipalParts:
            return .init(title: "Qal Principal Parts", items: [
                .init(text: "קָטַל", definition: "To kill", parsing: "(Strong)", details: "Yiqtol: יִקְטֹל \nInf. Const: קְטֹל \nParticiple: קֹטֵל"),
                .init(text: "בָּנָה", definition: "To make, do", parsing: "(III-ח)", details: "Yiqtol: יִבְנֶה \nInf. Const: בְּנוֹת \nParticiple: בּוֹנֶה"),
                .init(text: "עָמַד", definition: "To stand", parsing: "(I-ע)\n", details: "Yiqtol: יַעֲמֹד \nInf. Const: עֲמֹד \nParticiple: עֹמֵד"),
                .init(text: "בָּחַר", definition: "To choose", parsing: "(II-Guttural)", details: "Yiqtol: יִבְחַר \nInf. Const: בְּחֹר \nParticiple: בֹּחֵר"),
                .init(text: "שָׁמַע", definition: "To hear, listen", parsing: "(III-ח/ע)\n", details: "Yiqtol: יִשְׁמַע \nInf. Const: שְׁמֹעַ \nParticiple: שֹׁמֵעַ"),
                .init(text: "מָצָא", definition: "To find", parsing: "(III-א)", details: "Yiqtol: יִמְצָא \nInf. Const: מְצֹא \nParticiple: מֹצֵא"),
                .init(text: "חָטָא", definition: "To sin", parsing: "(I-ח + III-א)", details: "Yiqtol: יֶחֱטָא \nInf. Const: חֲטֹא \nParticiple: חוֹטֵא"),
                .init(text: "נָפַל", definition: "To fall", parsing: "(I-נ)", details: "Yiqtol: יִפֹּל \nInf. Const: נְפֹל \nParticiple: נֹפֵל"),
                .init(text: "שָׁב", definition: "To return", parsing: "(I-י)", details: "Yiqtol: יָשׁוּב \nInf. Const: שׁוּב \nParticiple: שָׁב"),
                .init(text: "סָבַב", definition: "To encircle/surround/go about", parsing: "(Geminate)", details: "Yiqtol: יָסֹב \nInf. Const: סְבֹב \nParticiple: סֹבֵב"),
                .init(text: "יָשַׁב", definition: "To sit/dwell", parsing: "(I-י)", details: "Yiqtol: יֵשֵׁב,תֵּשֵׁב \nInf. Const: שֶׁבֶת \nParticiple: יֹשֵׁב"),
                .init(text: "יָרַשׁ", definition: "To possess", parsing: "(I-י)", details: "Yiqtol: יִירַשׁ \nInf. Const: רֶשֶׁת \nParticiple: יוֹרֵשׁ"),
                .init(text: "אָמַר", definition: "say", parsing: "(I-א)", details: "Yiqtol: יֹאמַר \nInf. Const: לֵאמֹר \nParticiple: אֹמֵר"),
                .init(text: "אָהַב", definition: "to love", parsing: "(I-א)", details: "Yiqtol: יֶאֱהַב \nInf. Const: אַהֲבַת \nParticiple: אֹהֵב"),
                
            ])
        case .niphalPrincipalParts:
            return .init(title: "Niphal Principal Parts", items: [
                .init(text: "נִקְטַל", definition: "", parsing: "Niphal Qatal", details: "The preformative is נ. The preformative נ has an i-class vowel. The stem vowel is a-class."),
                .init(text: "יִקָּטֵל", definition: "", parsing: "Niphal Yiqtol", details: "They appear to have had a preformative הִן. The נ of the הִן preformative has assimilated to the first letter of the root and doubled it. "),
                .init(text: "הִקָּטֵל", definition: "", parsing: "Niphal Infinitive Construct", details: "They appear to have had a preformative הִן. The נ of the הִן preformative has assimilated to the first letter of the root and doubled it. "),
                .init(text: "נִקְטָל", definition: "", parsing: "Niphal Participle", details: "The preformative is נ. The preformative נ has an i-class vowel. The stem vowel is a-class."),
            ])
        case .pielPrincipalParts:
            return .init(title: "Piel Principal Parts", items: [
                .init(text: "קִטֵּל", definition: "", parsing: "Piel Qatal 3ms", details: "The qatal always has the i-class vowel under the first radical. The qatal stem vowel consistently is as follows: For the 3ms, there is an i-class stem vowel (קִטֵּל) which reduces in the 3fs and (קִטְּלָה) 3cp (קִטְּלוּ). In the second and first person, the stem vowel is a-class (קִטַּ֫לְתָּ)."),
                .init(text: "קִטַּ֫לְתָּ", definition: "", parsing: "Piel Qatal 2ms", details: "The qatal always has the i-class vowel under the first radical. The qatal stem vowel consistently is as follows: For the 3ms, there is an i-class stem vowel (קִטֵּל), which reduces in the 3fs and (קִטְּלָה) 3cp (קִטְּלוּ). In the second and first person, the stem vowel is a-class (קִטַּ֫לְתָּ)."),
                .init(text: "יְקַטֵּל", definition: "", parsing: "Piel Yiqtol", details: "In the yiqtol, the infinitive construct, and the participle (that is, in all non-qatal forms), we have the following pattern. The root has a vowel pattern having a-class with the first radical followed by i-class for the stem vowel. If there is a preformative (yiqtol and participle), it has a Shewa."),
                .init(text: "קַטֵּל", definition: "", parsing: "Piel Infinitive Construct", details: "In the yiqtol, the infinitive construct, and the participle (that is, in all non-qatal forms), we have the following pattern. The root has a vowel pattern having a-class with the first radical followed by i-class for the stem vowel. If there is a preformative (yiqtol and participle), it has a Shewa."),
                .init(text: "מְקַטֵּל", definition: "", parsing: "Piel Participle", details: "In the yiqtol, the infinitive construct, and the participle (that is, in all non-qatal forms), we have the following pattern. The root has a vowel pattern having a-class with the first radical followed by i-class for the stem vowel. If there is a preformative (yiqtol and participle), it has a Shewa."),
            ])
        case .hiphilPrincipalParts:
            return .init(title: "Hiphil Principal Parts", items: [
                .init(text: "הִקְטִיל", definition: "", parsing: "Hiphil Qatal 3ms", details: "The qatal has the i-class vowel under the preformative ה. The stem vowel is as follows: In the third person forms, the stem vowel is typically Hireq-Yod (i-class). In the second person forms, the stem vowel is typically Pathach (a-class)."),
                .init(text: "הִקְטַ֫לְתָּ", definition: "", parsing: "Hiphil Qatal 2ms", details: "The qatal has the i-class vowel under the preformative ה. The stem vowel is as follows: In the third person forms, the stem vowel is typically Hireq-Yod (i-class). In the second person forms, the stem vowel is typically Pathach (a-class)."),
                .init(text: "יַקְטִיל", definition: "", parsing: "Hiphil Yiqtol", details: "In all the other forms (yiqtol, participle, imperative, and infinitive construct), the vowel pattern is typically Pathach under the preformative followed by Hireq-Yod. The i-class stem vowel is Tsere or Seghol in some forms, such as the imperative ms (הַקְטֵל)."),
                .init(text: "הַקְטִיל", definition: "", parsing: "Hiphil Infinitive Construct", details: "In all the other forms (yiqtol, participle, imperative, and infinitive construct), the vowel pattern is typically Pathach under the preformative followed by Hireq-Yod. The i-class stem vowel is Tsere or Seghol in some forms, such as the imperative ms (הַקְטֵל)."),
                .init(text: "מַקְטִיל", definition: "", parsing: "Hiphil Participle", details: "In all the other forms (yiqtol, participle, imperative, and infinitive construct), the vowel pattern is typically Pathach under the preformative followed by Hireq-Yod. The i-class stem vowel is Tsere or Seghol in some forms, such as the imperative ms (הַקְטֵל)."),
            ])
        case .pualPrincipalParts:
            return .init(title: "Pual Principal Parts", items: [
                .init(text: "קֻטַּל", definition: "", parsing: "Pual Qatal", details: "The Pual has only one vowel pattern. It is “u-class followed by a-class.” The middle radical of the root is doubled with a Daghesh Forte."),
                .init(text: "יְקֻטַּל", definition: "", parsing: "Pual Yiqtol", details: "The Pual has only one vowel pattern. It is “u-class followed by a-class.” The middle radical of the root is doubled with a Daghesh Forte. If there is a yiqtol or participle preformative, it has a Shewa"),
                .init(text: "קֻטַּל", definition: "", parsing: "Pual Infinitive Construct", details: "The Pual has only one vowel pattern. It is “u-class followed by a-class.” The middle radical of the root is doubled with a Daghesh Forte."),
                .init(text: "מְקֻטָּל", definition: "", parsing: "Pual Participle", details: "The Pual has only one vowel pattern. It is “u-class followed by a-class.” The middle radical of the root is doubled with a Daghesh Forte. The participle preformative is מ."),
            ])
        case .hophalPrincipalParts:
            return .init(title: "Hophal Principal Parts", items: [
                .init(text: "הָקְטַל", definition: "", parsing: "Hophal Qatal", details: "The Hophal is the passive of the Hiphil. Like the Hiphil, the Hophal has a ה preformative. Like the Pual, the Hophal has only one vowel pattern. It is u-class vowel followed by an a-class vowel. The distinctive Hophal preformative is ה."),
                .init(text: "יָקְטַל", definition: "", parsing: "Hophal Qatal Yiqtol", details: "The Hophal is the passive of the Hiphil. Like the Hiphil, the Hophal has a ה preformative. Like the Pual, the Hophal has only one vowel pattern. It is u-class vowel followed by an a-class vowel. The distinctive Hophal preformative is ה."),
                .init(text: "הָקְטַל", definition: "", parsing: "Hophal Infinitive Construct", details: "The Hophal is the passive of the Hiphil. Like the Hiphil, the Hophal has a ה preformative. Like the Pual, the Hophal has only one vowel pattern. It is u-class vowel followed by an a-class vowel. The distinctive Hophal preformative is ה."),
                .init(text: "מָקְטָל", definition: "", parsing: "Hophal Participle", details: "The Hophal is the passive of the Hiphil. Like the Hiphil, the Hophal has a ה preformative. Like the Pual, the Hophal has only one vowel pattern. It is u-class vowel followed by an a-class vowel. The distinctive Hophal preformative is ה. The participle preformative is מ."),
            ])
        case .hithpaelPrincipalParts:
            return .init(title: "Hithpael Principal Parts", items: [
                .init(text: "הִתְקַטֵּל", definition: "", parsing: "Hithpael Qatal 3ms", details: "The stem has a preformative הִת. Like the Pual and Hophal, the Hithpael has only one basic vowel pattern. It is “a-class followed by i-class” (the preformative הִת is not counted in the vowel pattern). The middle radical of the root is doubled with a Daghesh Forte."),
                .init(text: "הִתְקַטַּ֫לְתָּ", definition: "", parsing: "Hithpael Qatal 2ms", details: "The stem has a preformative הִת. Like the Pual and Hophal, the Hithpael has only one basic vowel pattern. It is “a-class followed by i-class” (the preformative הִת is not counted in the vowel pattern). The middle radical of the root is doubled with a Daghesh Forte."),
                .init(text: "יִתְקַטֵּל", definition: "", parsing: "Hithpael Yiqtol", details: "The stem has a preformative הִת. Like the Pual and Hophal, the Hithpael has only one basic vowel pattern. It is “a-class followed by i-class” (the preformative הִת is not counted in the vowel pattern). The middle radical of the root is doubled with a Daghesh Forte."),
                .init(text: "הִתְקַטֵּל", definition: "", parsing: "Hithpael Infinitive Construct", details: "The stem has a preformative הִת. Like the Pual and Hophal, the Hithpael has only one basic vowel pattern. It is “a-class followed by i-class” (the preformative הִת is not counted in the vowel pattern). The middle radical of the root is doubled with a Daghesh Forte."),
                .init(text: "מִתְקַטֵּל", definition: "", parsing: "Hithpael Participle", details: "The stem has a preformative הִת. The participle adds מ to the preformative הִת but displaces the ה, forming מִת. Like the Pual and Hophal, the Hithpael has only one basic vowel pattern. It is “a-class followed by i-class” (the preformative הִת is not counted in the vowel pattern). The middle radical of the root is doubled with a Daghesh Forte."),
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
        let parsing: String
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
