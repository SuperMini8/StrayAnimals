//
//  AnimalEnum.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/11/25.
//

import Foundation
import UIKit
// MARK: - 台灣地區
/// 台灣地區
enum TaiwanArea: Int, Codable, CaseIterable {
    /// 02 台北市
    case taipeiCity = 2
    /// 03 新北市
    case newTaipeiCity = 3
    /// 04 基隆市
    case keelungCity = 4
    /// 05 宜蘭縣
    case yilanCounty = 5
    /// 06 桃園縣
    case taoyuanCity = 6
    /// 07 新竹縣
    case hsinchuCounty = 7
    /// 08 新竹市
    case hsinchuCity = 8
    /// 09 苗栗縣
    case miaoliCounty = 9
    /// 10 台中市
    case taichungCity = 10
    /// 11 彰化縣
    case changhuaCounty = 11
    /// 12 南投縣
    case nantouCounty = 12
    /// 13 雲林縣
    case yunlinCounty = 13
    /// 14 嘉義縣
    case chiayiCounty = 14
    /// 15 嘉義市
    case chiayiCity = 15
    /// 16 台南市
    case tainanCity = 16
    /// 17 高雄市
    case kaohsiungCity = 17
    /// 18 屏東縣
    case pingtungCounty = 18
    /// 19 花蓮縣
    case hualienCounty = 19
    /// 20 台東縣
    case taitungCounty = 20
    /// 21 澎湖縣
    case penghuCounty = 21
    /// 22 金門縣
    case kinmenCounty = 22
    /// 23 連江縣（馬祖）
    case lienchiangCounty = 23
    /// 99
    case unknown = 99
    
    init(from decoder: any Decoder) throws {
        self = try TaiwanArea(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    
    func areaName() -> String {
        var name: String = ""
        switch self {
        case .keelungCity:
            name = "基隆市"
        case .taipeiCity:
            name = "台北市"
        case .newTaipeiCity:
            name = "新北市"
        case .taoyuanCity:
            name = "桃園縣"
        case .hsinchuCity:
            name = "新竹市"
        case .hsinchuCounty:
            name = "新竹縣"
        case .miaoliCounty:
            name = "苗栗縣"
        case .taichungCity:
            name = "台中市"
        case .changhuaCounty:
            name = "彰化縣"
        case .nantouCounty:
            name = "南投縣"
        case .yunlinCounty:
            name = "雲林縣"
        case .chiayiCity:
            name = "嘉義市"
        case .chiayiCounty:
            name = "嘉義縣"
        case .tainanCity:
            name = "台南市"
        case .kaohsiungCity:
            name = "高雄市"
        case .pingtungCounty:
            name = "屏東縣"
        case .taitungCounty:
            name = "台東縣"
        case .hualienCounty:
            name = "花蓮縣"
        case .yilanCounty:
            name = "宜蘭縣"
        case .penghuCounty:
            name = "澎湖縣"
        case .kinmenCounty:
            name = "金門縣"
        case .lienchiangCounty:
            name = "連江縣（馬祖）"
        case .unknown:
            name = "未知區域"
        }
        return name
    }
    
}
// MARK: - 收容所ID
/// 收容所ID
enum PetShelter: Int, Codable {
    /// 48 基隆市寵物銀行
    case keelungPetBank = 48
    /// 49 臺北市動物之家
    case taipeiPetHome = 49
    /// 50 新北市板橋區公立動物之家
    case newTaipeiBanqiaoPetHome = 50
    /// 51 新北市新店區公立動物之家
    case newTaipeiXindianPetHome = 51
    /// 53 新北市中和區公立動物之家
    case newTaipeiZhonghePetHome = 53
    /// 55 新北市淡水區公立動物之家
    case newTaipeiTamsuiPetHome = 55
    /// 56 新北市瑞芳區公立動物之家
    case newTaipeiRuifangPetHome = 56
    /// 58 新北市五股區公立動物之家
    case newTaipeiWuguPetHome = 58
    /// 59 新北市八里區公立動物之家
    case newTaipeiBaliPetHome = 59
    /// 60 新北市三芝區公立動物之家
    case newTaipeiSanzhiPetHome = 60
    /// 61 桃園市動物保護教育園區
    case taoyuanAnimalProtectionEducationPark = 61
    /// 62 新竹市動物收容所
    case hsinchuCityAnimalShelter = 62
    /// 63 新竹縣動物收容所
    case hsinchuCountyAnimalShelter = 63
    /// 67 臺中市動物之家南屯園區
    case taichungNantunPetHome = 67
    /// 68 臺中市動物之家后里園區
    case taichungHouliPetHome = 68
    /// 69 彰化縣流浪狗中途之家
    case changhuaStrayDogsHome = 69
    /// 70 南投縣公立動物收容所
    case nantouAnimalShelter = 70
    /// 71 嘉義市流浪犬收容中心
    case chiayiCityStrayDogShelter = 71
    /// 72 嘉義縣流浪犬中途之家
    case chiayiCountyStrayDogHome = 72
    /// 73 臺南市動物之家灣裡站
    case tainanWanliPetHome = 73
    /// 74 臺南市動物之家善化站
    case tainanShanhuaPetHome = 74
    /// 75 高雄市壽山動物保護教育園區
    case kaohsiungShoushanAnimalProtectionEducationPark = 75
    /// 76 高雄市燕巢動物保護關愛園區
    case kaohsiungYanchaoAnimalProtectionPark = 76
    /// 77 屏東縣流浪動物收容所
    case pingtungStrayAnimalShelter = 77
    /// 78 宜蘭縣流浪動物中途之家
    case yilanStrayAnimalHome = 78
    /// 79 花蓮縣流浪犬中途之家
    case hualienStrayDogHome = 79
    /// 80 臺東縣動物收容中心
    case taitungAnimalShelter = 80
    /// 81 連江縣流浪犬收容中心
    case lienchiangStrayDogShelter = 81
    /// 82 金門縣動物收容中心
    case kinmenAnimalShelter = 82
    /// 83 澎湖縣流浪動物收容中心
    case penghuStrayAnimalShelter = 83
    /// 89 雲林縣流浪動物收容所
    case yunlinStrayAnimalShelter = 89
    /// 92 新北市政府動物保護防疫處
    case newTaipeiAnimalProtectionPark = 92
    /// 96 苗栗縣生態保育教育中心
    case miaoliEcologyConservationEducationCenter = 96
    /// 999 未知收容所
    case unknown = 999
    
    init(from decoder: any Decoder) throws {
        self = try PetShelter(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    
    func shelterName() -> String {
        var name: String = ""
        switch self {
        case .keelungPetBank:
            name = "基隆市寵物銀行"
        case .taipeiPetHome:
            name = "臺北市動物之家"
        case .newTaipeiBanqiaoPetHome:
            name = "新北市板橋區公立動物之家"
        case .newTaipeiXindianPetHome:
            name = "新北市新店區公立動物之家"
        case .newTaipeiZhonghePetHome:
            name = "新北市中和區公立動物之家"
        case .newTaipeiTamsuiPetHome:
            name = "新北市淡水區公立動物之家"
        case .newTaipeiRuifangPetHome:
            name = "新北市瑞芳區公立動物之家"
        case .newTaipeiWuguPetHome:
            name = "新北市五股區公立動物之家"
        case .newTaipeiBaliPetHome:
            name = "新北市八里區公立動物之家"
        case .newTaipeiSanzhiPetHome:
            name = "新北市三芝區公立動物之家"
        case .taoyuanAnimalProtectionEducationPark:
            name = "桃園市動物保護教育園區"
        case .hsinchuCityAnimalShelter:
            name = "新竹市動物收容所"
        case .hsinchuCountyAnimalShelter:
            name = "新竹縣動物收容所"
        case .taichungNantunPetHome:
            name = "臺中市動物之家南屯園區"
        case .taichungHouliPetHome:
            name = "臺中市動物之家后里園區"
        case .changhuaStrayDogsHome:
            name = "彰化縣流浪狗中途之家"
        case .nantouAnimalShelter:
            name = "南投縣公立動物收容所"
        case .chiayiCityStrayDogShelter:
            name = "嘉義市流浪犬收容中心"
        case .chiayiCountyStrayDogHome:
            name = "嘉義縣流浪犬中途之家"
        case .tainanWanliPetHome:
            name = "臺南市動物之家灣裡站"
        case .tainanShanhuaPetHome:
            name = "臺南市動物之家善化站"
        case .kaohsiungShoushanAnimalProtectionEducationPark:
            name = "高雄市壽山動物保護教育園區"
        case .kaohsiungYanchaoAnimalProtectionPark:
            name = "高雄市燕巢動物保護關愛園區"
        case .pingtungStrayAnimalShelter:
            name = "屏東縣流浪動物收容所"
        case .yilanStrayAnimalHome:
            name = "宜蘭縣流浪動物中途之家"
        case .hualienStrayDogHome:
            name = "花蓮縣流浪犬中途之家"
        case .taitungAnimalShelter:
            name = "臺東縣動物收容中心"
        case .lienchiangStrayDogShelter:
            name = "連江縣流浪犬收容中心"
        case .kinmenAnimalShelter:
            name = "金門縣動物收容中心"
        case .penghuStrayAnimalShelter:
            name = "澎湖縣流浪動物收容中心"
        case .yunlinStrayAnimalShelter:
            name = "雲林縣流浪動物收容所"
        case .newTaipeiAnimalProtectionPark:
            name = "新北市政府動物保護防疫處"
        case .miaoliEcologyConservationEducationCenter:
            name = "苗栗縣生態保育教育中心"
        case .unknown:
            name = "未知收容所"
        }
        return name
    }
    
}
// MARK: - 寵物類型
/// 寵物類型
enum AnimalKind: String, Codable, CaseIterable {
    
    case dog = "狗"
    case cat = "貓"
    case other = "其他"
    
    init(from decoder: any Decoder) throws {
        self = try AnimalKind(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .other
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
// MARK: - 寵物性別
/// 寵物性別
enum AnimalSex: String, Codable, CaseIterable {
    case male = "M"
    case female = "F"
    case unknown = "N"
    
    init(from decoder: any Decoder) throws {
        self = try AnimalSex(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
// MARK: - 寵物體型
/// 寵物體型
enum AnimalBodyType: String, Codable, CaseIterable {
    case small = "SMALL"
    case medium = "MEDIUM"
    case big = "BIG"
    case unknown = "UNKNOWN"
    
    init(from decoder: any Decoder) throws {
        self = try AnimalBodyType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
// MARK: - 寵物年齡
/// 寵物年齡
enum AnimalAge: String, Codable, CaseIterable {
    case child = "CHILD"
    case adult = "ADULT"
    case unknown = "UNKNOWN"
    
    init(from decoder: any Decoder) throws {
        self = try AnimalAge(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
// MARK: - 寵物絕育狀態
/// 寵物絕育狀態
enum AnimalSterilization: String, Codable {
    case sterilized = "T"
    case notSterilized = "F"
    case unknown = "N"
    
    init(from decoder: any Decoder) throws {
        self = try AnimalSterilization(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
// MARK: - 狂犬病施打狀態
/// 狂犬病施打狀態
enum AnimalBacterinStatus: String, Codable {
    case vaccinated = "T"
    case notVaccinated = "F"
    case unknown = "N"
    
    init(from decoder: any Decoder) throws {
        self = try AnimalBacterinStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
// MARK: - 寵物狀態
/// 寵物狀態
enum AnimalStatus: String, Codable {
    case none = "NONE"
    case openAdoption = "OPEN"
    case adopted = "ADOPTED"
    case other = "OTHER"
    case dead = "DEAD"
    
    init(from decoder: any Decoder) throws {
        self = try AnimalStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .none
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }    
}
