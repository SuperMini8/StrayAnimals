//
//  LocalizedHelper.swift
//  RemitExchange
//
//  Created by Elma YEH 葉品妤 on 2025/8/12.
//

import Foundation

enum Language: String {
    case english = "en"
    case filipino_Philippines = "fil-PH"
    case indonesian = "id"
    case thai = "th"
    case vietnamese = "vi"
}

class LocalizedHelper {
    
    static let shared = LocalizedHelper()
    
    private init() {}
    
    var currentLanguage: Language = .english
    
}

func LString(_ string: String, commit: String = "") -> String {
    guard let path = Bundle.main.path(forResource: LocalizedHelper.shared.currentLanguage.rawValue,
                                ofType: "lproj"),
          let bundle = Bundle(path: path)
    else { return "" }
    
    return NSLocalizedString(string, bundle: bundle, comment: commit)
}
