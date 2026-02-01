//
//  PetData.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/11/24.
//

import Foundation

struct PetData: Codable {
    /// 01.動物的流水編號
    var animalId: Int
    /// 02.動物的收容編號
    var animalSubid: String
    /// 03.動物所屬縣市代碼
    var animalAreaPkid: TaiwanArea
    /// 04.動物所屬收容所代碼
    var animalShelterPkid: PetShelter
    /// 05.動物的實際所在地
    var animalPlace: String
    /// 06.動物的類型[貓 | 狗 | 鳥...]
    var animalKind: AnimalKind
    /// 07.動物的品種
    var animalVariety: String
    /// 08.動物性別[M | F | N]（公、母、未輸入）
    var animalSex: AnimalSex
    /// 09.動物體型[SMALL | MEDIUM | BIG]（小型、中型、大型）
    var animalBodytype: AnimalBodyType
    /// 10.動物毛色[黑色 | 灰色 | 白色...]
    var animalColour: String
    /// 11.動物年紀[CHILD | ADULT]（幼年、成年）
    var animalAge: AnimalAge
    /// 12.是否絕育[T | F | N]（是、否、未輸入）
    var animalSterilization: AnimalSterilization
    /// 13.是否施打狂犬病疫苗[T | F | N]（是、否、未輸入）
    var animalBacterin: AnimalBacterinStatus
    /// 14.動物尋獲地（文字敘述）
    var animalFoundplace: String
    /// 15.動物網頁標題（文字敘述）
    var animalTitle: String
    /// 16.動物狀態[NONE | OPEN | ADOPTED | OTHER | DEAD]（未公告、開放認養、已認養、其他、死亡）
    var animalStatus: AnimalStatus
    /// 17.資料備註（文字敘述）
    var animalRemark: String
    /// 18.其他說明（此欄位資料僅供後台使用人員參考、紀錄，資訊不提供給一般民眾）
    var animalCaption: String
    /// 開放認養時間（起）ex: 2025-11-17
    var animalOpendate: Date
    /// 開放認養時間（迄）ex: 2999-12-31
    var animalCloseddate: Date
    /// 動物資料異動時間 ex: 2025/12/12
    var animalUpdate: Date
    /// 動物資料建立時間 ex: 2025/11/17
    var animalCreatetime: Date
    /// 動物所屬收容所名稱
    var shelterName: String
    /// 圖片名稱
    var albumFile: String
    /// 異動時間
    var albumUpdate: String
    /// 資料更新時間 ex: 2025/12/12
    var cDate: Date
    /// (動物所屬收容所)地址
    var shelterAddress: String
    /// 連絡電話
    var shelterTel: String
}
