//
//  StrayAnimalListQuery.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/1/30.
//

import Foundation

struct StrayAnimalListQuery {
    
    enum QueryKey: String {
        case top = "$top"
        case skip = "$skip"
        case animalID = "animal_id"
        case subID = "animal_subid"
        case areaID = "animal_area_pkid"
        case animalPlace = "animal_place"
        case animalKind = "animal_kind"
        case animalVariety = "animal_Variety"
        case animalSex = "animal_sex"
        case animalBodyType = "animal_bodytype"
        case animalColor = "animal_colour"
        case animalAge = "animal_age"
        case animalSterilization = "animal_sterilization"
        case animalBacterin = "animal_bacterin"
        case animalFoundPlace = "animal_foundplace"
        case animalStatus = "animal_status"
        case animalOpenDate = "animal_opendate"
        case shelterName = "shelter_name"
    }
    /// 取最前筆數
    var top: Int?
    /// 跳過筆數
    var skip: Int?
    /// 動物的流水編號
    var animalID: Int?
    /// 動物的收容編號
    var subID: String?
    /// 動物所屬縣市代碼
    var areaID: TaiwanArea?
    /// 動物的實際所在地
    var animalPlace: String?
    /// 動物的類型
    var animalKind: AnimalKind?
    /// 動物的品種
    var animalVariety: String?
    /// 動物性別
    var animalSex: AnimalSex?
    /// 動物體型
    var animalBodyType: AnimalBodyType?
    /// 動物毛色
    var animalColor: String?
    /// 動物年紀
    var animalAge: AnimalAge?
    /// 是否絕育
    var animalSterilization: AnimalSterilization?
    /// 是否施打狂犬病疫苗
    var animalBacterin: AnimalBacterinStatus?
    /// 動物尋獲地
    var animalFoundPlace: String?
    /// 動物狀態
    var animalStatus: AnimalStatus?
    /// 開放認養時間（起）
    var animalOpenDate: String?
    /// 動物所屬收容所名稱
    var shelterName: PetShelter?
    
    func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        func add(_ key: QueryKey, _ value: String?) {
            guard let value, !value.isEmpty else { return }
            items.append(URLQueryItem(name: key.rawValue, value: value))
        }
        add(.top, top.map(String.init))
        add(.skip, skip.map(String.init))
        add(.animalID, animalID.map(String.init))
        add(.subID, subID)
        add(.areaID, areaID.map { String($0.rawValue) })
        add(.animalPlace, animalPlace)
        add(.animalKind, animalKind?.rawValue)
        add(.animalVariety, animalVariety)
        add(.animalSex, animalSex?.rawValue)
        add(.animalBodyType, animalBodyType?.rawValue)
        add(.animalColor, animalColor)
        add(.animalAge, animalAge?.rawValue)
        add(.animalSterilization, animalSterilization?.rawValue)
        add(.animalBacterin, animalBacterin?.rawValue)
        add(.animalFoundPlace, animalFoundPlace)
        add(.animalStatus, animalStatus?.rawValue)
        add(.animalOpenDate, animalOpenDate)
        add(.shelterName, shelterName?.shelterName())
        return items
    }
    /// 下一頁資料 or 第x頁資料
    mutating func setPage(_ page: Int, size: Int) {
        guard page > 0, size > 0 else {
            assertionFailure("StrayAnimalListQuery Invalid page or size: page=\(page), size=\(size)")
            return
        }
        top = size
        skip = (page - 1) * size
    }

}
