//
//  CategoryItemViewModel.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/7.
//

import UIKit
// TODO: 做成點擊後可以開啟清單的樣式
enum ListCategory: Int, CaseIterable {
    case all = 0
    case kindDog
    case kindCat
    case kindOther
    case ageChild
    case ageAdult
    
    /// 顯示用的文字
    func title() -> String {
        switch self {
        case .all:
            return "全部"
        case .kindDog:
            return AnimalKind.dog.rawValue
        case .kindCat:
            return AnimalKind.cat.rawValue
        case .kindOther:
            return AnimalKind.other.rawValue
        case .ageChild:
            return AnimalAge.child.AgeText()
        case .ageAdult:
            return AnimalAge.adult.AgeText()
        }
    }
    
    /// 帶入參數使用的值
    func queryValue() -> String {
        switch self {
        case .all:
            return "全部"
        case .kindDog:
            return AnimalKind.dog.rawValue
        case .kindCat:
            return AnimalKind.cat.rawValue
        case .kindOther:
            return AnimalKind.other.rawValue
        case .ageChild:
            return AnimalAge.child.rawValue
        case .ageAdult:
            return AnimalAge.adult.rawValue
        }
    }
    
}

final class CategoryItemViewModel: Hashable {
    
    let category: ListCategory
    let categoryName: String
    var isSelected: Bool = false
    
    var backgroundColor: UIColor {
        return isSelected ? UIColor.navigationBar : UIColor.white
    }
    
    var borderWidth: CGFloat {
        return isSelected ? 0.0 : 1.0
    }
    
    var selectedImage: UIImage {
        return isSelected ? UIImage.check : UIImage.more
    }
    
    init(categoryType: ListCategory, isSelected: Bool) {
        self.category = categoryType
        self.categoryName = categoryType.title()
        self.isSelected = isSelected
    }
    
    static func ==(lhs: CategoryItemViewModel, rhs: CategoryItemViewModel) -> Bool {
        lhs.category == rhs.category
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(category)
    }
    
}
