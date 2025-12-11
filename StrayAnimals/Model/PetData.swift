//
//  PetData.swift
//  StrayAnimals
//
//  Created by 小八 on 2025/11/24.
//

struct PetData: Codable {
    /// 01.動物的流水編號
    var animal_id: Int
    /// 02.動物的收容編號
    var animal_subid: String
    /// 03.動物所屬縣市代碼
    var animal_area_pkid: TaiwanArea
    /// 04.動物所屬收容所代碼
    var animal_shelter_pkid: PetShelter
    /// 05.動物的實際所在地
    var animal_place: String
    /// 06.動物的類型[貓 | 狗 | 鳥...]
    var animal_kind: AnimalKind
    /// 07.動物的品種
    var animal_Variety: String
    /// 08.動物性別[M | F | N]（公、母、未輸入）
    var animal_sex: AnimalSex
    /// 09.動物體型[SMALL | MEDIUM | BIG]（小型、中型、大型）
    var animal_bodytype: AnimalBodyType
    /// 10.動物毛色[黑色 | 灰色 | 白色...]
    var animal_colour: String
    /// 11.動物年紀[CHILD | ADULT]（幼年、成年）
    var animal_age: AnimalAge
    /// 12.是否絕育[T | F | N]（是、否、未輸入）
    var animal_sterilization: AnimalSterilization
    /// 13.是否施打狂犬病疫苗[T | F | N]（是、否、未輸入）
    var animal_bacterin: AnimalBacterinStatus
    /// 14.動物尋獲地（文字敘述）
    var animal_foundplace: String
    /// 15.動物網頁標題（文字敘述）
    var animal_title: String
    /// 16.動物狀態[NONE | OPEN | ADOPTED | OTHER | DEAD]（未公告、開放認養、已認養、其他、死亡）
    var animal_status: AnimalStatus
    /// 17.資料備註（文字敘述）
    var animal_remark: String
    /// 18.其他說明（此欄位資料僅供後台使用人員參考、紀錄，資訊不提供給一般民眾）
    var animal_caption: String
    /// 開放認養時間（起）
    var animal_opendate: String
    /// 開放認養時間（迄）
    var animal_closeddate: String
    /// 動物資料異動時間
    var animal_update: String
    /// 動物資料建立時間
    var animal_createtime: String
    /// 動物所屬收容所名稱
    var shelter_name: String
    /// 圖片名稱
    var album_file: String
    /// 異動時間
    var album_update: String
    /// 資料更新時間
    var cDate: String
    /// (動物所屬收容所)地址
    var shelter_address: String
    /// 連絡電話
    var shelter_tel: String
}
