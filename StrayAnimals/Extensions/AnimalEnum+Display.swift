//
//  AnimalEnum+Display.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/9/4.
//

import UIKit
// MARK: - AnimalKind
extension AnimalKind {
    func defaultImage() -> UIImage? {
        switch self {
        case .dog:
            return UIImage.dog
        case .cat:
            return UIImage.cat
        case .other:
            return UIImage.paw
        }
    }
}
// MARK: - AnimalSex
extension AnimalSex {
    func sexImage() -> UIImage {
        switch self {
        case .male:
            return UIImage.gender
        case .female:
            return UIImage.female
        case .unknown:
            return UIImage.questionMark
        }
    }
    
    func displaySexName() -> String {
        switch self {
        case .male:
            return "公"
        case .female:
            return "母"
        case .unknown:
            return "未知"
        }
    }
}
// MARK: - AnimalBodyType
extension AnimalBodyType {
    func bodyTypeText() -> String {
        switch self {
        case .small:
            return "小型"
        case .medium:
            return "中型"
        case .big:
            return "大型"
        case .unknown:
            return "未知"
        }
    }
}
// MARK: - AnimalAge
extension AnimalAge {
    func ageText() -> String {
        switch self {
        case .child:
            return "幼年"
        case .adult:
            return "成年"
        case .unknown:
            return "未知"
        }
    }
}
// MARK: - AnimalSterilization
extension AnimalSterilization {
    func sterilizationText() -> String {
        var text: String = ""
        switch self {
        case .sterilized:
            text = "已絕育"
        case .notSterilized:
            text = "尚未絕育"
        case .unknown:
            text = "未知"
        }
        return text
    }
}
// MARK: - AnimalBacterinStatus
extension AnimalBacterinStatus {
    func statusText() -> String {
        switch self {
        case .vaccinated:
            return "已施打"
        case .notVaccinated:
            return "尚未施打"
        case .unknown:
            return "未知"
        }
    }
}
// MARK: - AnimalStatus
extension AnimalStatus {
    func statusText() -> String {
        switch self {
        case .none:
            return "未公告"
        case .openAdoption:
            return "開放認養"
        case .adopted:
            return "已認養"
        case .other:
            return "其他"
        case .dead:
            return "死亡"
        }
    }
    
    func backgroundColor() -> UIColor {
        switch self {
        case .openAdoption:
            return .openAdoptionBackground
        default:
            return .statusNormalBackground
        }
    }
    
    func textColor() -> UIColor {
        switch self {
        case .openAdoption:
            return .openAdoptionText
        default:
            return .statusNormalText
        }
    }
}

