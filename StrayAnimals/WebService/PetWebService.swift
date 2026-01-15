//
//  PetWebService.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/1/15.
//

import Foundation

class PetWebService {
    
    private let petDataUrlString =  "https://data.moa.gov.tw/Service/OpenData/TransService.aspx?UnitId=QcbUEzN6E6DL"
    // 可使用的參數
    /// 取最前筆數
    var topAmount: Int?
    /// 跳過筆數
    var skipAmount: Int?
    /// 動物的流水編號
    var animalID: Int?
    /// 動物的收容編號
    var subID: String?
    /// 動物所屬縣市代碼
    var areaID: TaiwanArea?
    /// 動物的實際所在地
    var animalPlace: String?
    /// 動物的類型
    var animalKind: String?
    /// 動物的品種
    var animalVariety: String?
    /// 動物性別
    var animalSex: AnimalSex?
    /// 動物體型
    var animalBodyType: String?
    /// 動物毛色
    var animalColor: String?
    /// 動物年紀
    var animalAge: String?
    /// 是否絕育
    var animalSterilization: String?
    /// 是否施打狂犬病疫苗
    var animalBacterin: String?
    /// 動物尋獲地
    var animalFoundPlace: String?
    /// 動物狀態
    var animalStatus: String?
    /// 開放認養時間（起）
    var animalOpenDate: String?
    /// 動物所屬收容所名稱
    var shelterName: PetShelter?
    
    private func combinedURLString() -> String {
        
        var urlString = petDataUrlString
        
        if let topAmt = topAmount {
            urlString += "&$top=\(topAmt)"
        }
        
        if let skipAmt = skipAmount {
            urlString += "&$skip=\(skipAmt)"
        }
        
        if let petID = animalID {
            urlString += "&animal_id=\(petID)"
        }
        
        if let petSubID = subID {
            urlString += "&animal_subid=\(petSubID)"
        }
        
        if let petAreaID = areaID {
            urlString += "&animal_area_pkid=\(petAreaID.rawValue)"
        }
        
        if let placeText = animalPlace {
            urlString += "&animal_place=\(placeText)"
        }
        
        if let petKind = animalKind {
            urlString += "&animal_kind=\(petKind)"
        }
        
        if let petVariety = animalVariety {
            urlString += "&animal_Variety=\(petVariety)"
        }
        
        if let petSex = animalSex {
            urlString += "&animal_sex=\(petSex.rawValue)"
        }
        
        if let petBodyType = animalBodyType {
            urlString += "&animal_bodytype=\(petBodyType)"
        }
        
        if let petColor = animalColor {
            urlString += "&animal_color=\(petColor)"
        }
        
        if let petAge = animalAge {
            urlString += "&animal_age=\(petAge)"
        }
        
        if let petSterilization = animalSterilization {
            urlString += "&animal_sterilization=\(petSterilization)"
        }
        
        if let petBacterin = animalBacterin {
            urlString += "&animal_bacterin=\(petBacterin)"
        }
        
        if let petFoundPlace = animalFoundPlace {
            urlString += "&animal_foundplace=\(petFoundPlace)"
        }
        
        if let petStatus = animalStatus {
            urlString += "&animal_status=\(petStatus)"
        }
        
        if let petOpenDate = animalOpenDate {
            urlString += "&animal_opendate=\(petOpenDate)"
        }
        
        if let petShelterName = shelterName {
            urlString += "&shelter_name=\(petShelterName.shelterName())"
        }
        
        return urlString
    }
    
    func searchPetData(completion: @escaping ( ([PetData]?) -> Void) ) {
        
        guard let url = URL(string: combinedURLString()) else {
            completion(nil)
            return
        }
        
        WebService.urlSessionRequest(type: .get, url: url) { data, response, error in
            if error != nil {
                completion(nil)
                return
            }
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let petDatas = try JSONDecoder().decode([PetData].self, from: data)
                completion(petDatas)
            } catch {
                print(error)
                completion(nil)
            }
        }
        
    }
    
    
}
