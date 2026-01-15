
import Foundation

enum Language: String {
    case english = "en"
    case chinese = "zh-Hant"
}

class LocalizedHelper {
    
    static let shared = LocalizedHelper()
    
    private init() {}
    
    var currentLanguage: Language = .english
    
}

func LString(_ string: String, comment: String = "") -> String {
    guard let path = Bundle.main.path(forResource: LocalizedHelper.shared.currentLanguage.rawValue,
                                ofType: "lproj"),
          let bundle = Bundle(path: path)
    else { return "" }
    
    return NSLocalizedString(string, bundle: bundle, comment: comment)
}
