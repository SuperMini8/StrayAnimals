//
//  PetWebService.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/1/15.
//

import Foundation
import Combine

class PetWebService {
    
    private let petDataUrlString =  "https://data.moa.gov.tw/Service/OpenData/TransService.aspx?UnitId=QcbUEzN6E6DL"
    private let webService: WebService

    init(webService: WebService = WebService()) {
        self.webService = webService
    }
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
    
    private func buildURL() -> URL? {
        guard var components = URLComponents(string: petDataUrlString) else {
            return nil
        }
        
        var queryItems = components.queryItems ?? []
        
        if let topAmt = topAmount {
            queryItems.append(URLQueryItem(name: "$top", value: String(topAmt)))
        }
        
        if let skipAmt = skipAmount {
            queryItems.append(URLQueryItem(name: "$skip", value: String(skipAmt)))
        }
        
        if let petID = animalID {
            queryItems.append(URLQueryItem(name: "animal_id", value: String(petID)))
        }
        
        if let petSubID = subID {
            queryItems.append(URLQueryItem(name: "animal_subid", value: petSubID))
        }
        
        if let petAreaID = areaID {
            queryItems.append(URLQueryItem(name: "animal_area_pkid", value: String(petAreaID.rawValue)))
        }
        
        if let placeText = animalPlace {
            queryItems.append(URLQueryItem(name: "animal_place", value: placeText))
        }
        
        if let petKind = animalKind {
            queryItems.append(URLQueryItem(name: "animal_kind", value: petKind))
        }
        
        if let petVariety = animalVariety {
            queryItems.append(URLQueryItem(name: "animal_Variety", value: petVariety))
        }
        
        if let petSex = animalSex {
            queryItems.append(URLQueryItem(name: "animal_sex", value: petSex.rawValue))
        }
        
        if let petBodyType = animalBodyType {
            queryItems.append(URLQueryItem(name: "animal_bodytype", value: petBodyType))
        }
        
        if let petColor = animalColor {
            queryItems.append(URLQueryItem(name: "animal_color", value: petColor))
        }
        
        if let petAge = animalAge {
            queryItems.append(URLQueryItem(name: "animal_age", value: petAge))
        }
        
        if let petSterilization = animalSterilization {
            queryItems.append(URLQueryItem(name: "animal_sterilization", value: petSterilization))
        }
        
        if let petBacterin = animalBacterin {
            queryItems.append(URLQueryItem(name: "animal_bacterin", value: petBacterin))
        }
        
        if let petFoundPlace = animalFoundPlace {
            queryItems.append(URLQueryItem(name: "animal_foundplace", value: petFoundPlace))
        }
        
        if let petStatus = animalStatus {
            queryItems.append(URLQueryItem(name: "animal_status", value: petStatus))
        }
        
        if let petOpenDate = animalOpenDate {
            queryItems.append(URLQueryItem(name: "animal_opendate", value: petOpenDate))
        }
        
        if let petShelterName = shelterName {
            queryItems.append(URLQueryItem(name: "shelter_name", value: petShelterName.shelterName()))
        }
        
        components.queryItems = queryItems
        return components.url
    }
    
    func searchPetDataPublisher() -> AnyPublisher<[PetData], WebService.WebServiceError> {
        guard let url = buildURL() else {
            return Fail(error: WebService.WebServiceError.invalidURL("\(petDataUrlString) init URL is invalid"))
                .eraseToAnyPublisher()
        }
        
        return webService.request(method: .get, urlString: url.absoluteString)
    }
    
    func searchPetData(completion: @escaping ( ([PetData]?) -> Void) ) {
        
        guard let url = buildURL() else {
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
