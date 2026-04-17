//
//  PetInformationViewData.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/15.
//

import UIKit

// MARK: - View Data
/// 畫面顯示的 Data
/*
        圖片
 title:名字、性別、年紀
 subtitle:動物所在地
 標籤:|類型| |品種| |性別| |年紀|
 ----------------------------
 |狀態|
 |認養狀態|
 |開放認養時間|
 ----------------------------
 |動物資訊|
 |類型 | |體型 |
 |品種 | |毛色 |
 |性別 | |已絕育 |
 |年紀 | |狂犬病疫苗 |
 ----------------------------
 |收容所資訊|
 ----------------------------
 |備註|
 */
struct PetInformationViewData {
    /// 最上方的大圖片
    var image: UIImage?
    /// 名字、性別、年紀
    let title: String
    /// 動物所在地
    let subtitle: String
    /// |類型| |品種| |性別| |年紀|
    let badges: [BadgeViewData]
    /// 狀態
    let status: StatusCardViewData
    /// 動物資訊
    let infoRows: [InfoRowViewData]
    /// 收容所資訊
    let shelter: ShelterCardViewData?
    /// 備註
    let note: NoteCardViewData?
}
/// 標籤
struct BadgeViewData {
    let text: String
    let backgroundColor: UIColor
    let textColor: UIColor
}
/// 狀態卡片
struct StatusCardViewData {
    let statusText: String
    let statusBackgroundColor: UIColor
    let statusTextColor: UIColor
    let openDateText: String?
}
/// 詳細資料列
struct InfoRowViewData {
    let title: String
    let value: String
}
/// 收容所卡片
struct ShelterCardViewData {
    let name: String
    let adderss: String
    let phone: String
}
/// 備註卡片
struct NoteCardViewData {
    let foundPlace: String
    let remark: String?
    let updateDateText: String?
}
/// 點擊互動的種類
enum PetInformationRoute {
    /// 分享寵物資訊
    case share(item: [Any])
    /// 撥打收容所電話
    case call(phone: String)
    /// 打開地圖
    case openMap(address: String)
}
