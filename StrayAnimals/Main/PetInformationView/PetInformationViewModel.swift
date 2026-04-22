//
//  PetInformationViewModel.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/13.
//

import Foundation
import Combine

final class PetInformationViewModel {
    // MARK: - property
    @Published private(set) var viewData: PetInformationViewData?
    @Published private(set) var isImageLoading: Bool = false
    let route = PassthroughSubject<PetInformationRoute, Never>()
    
    private let petData: PetData
    private let imageLoader: ImageLoading
    private let dateFormatter: DateFormatter
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - method
    init(
        petData: PetData,
        imageLoader: ImageLoading = ImageLoader.shared
    ) {
        self.petData = petData
        self.imageLoader = imageLoader
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        self.dateFormatter = dateFormatter
    }
    
    func viewDidLoad() {
        viewData = makeViewData(form: petData)
        loadImageIfNeeded()
    }
    /// 將 Data 轉換成 View Data
    func makeViewData(form data: PetData) -> PetInformationViewData {
        // 先給預設的圖
        let defaultImage = data.animalKind.defaultIamge()
        
        let title: String = {
            return [
                data.animalVariety.trimmingCharacters(in: .whitespaces),
                data.animalSex.displaySexName(),
                data.animalAge.AgeText()
            ]
                .compactMap { $0 }
                .joined(separator: " ")
        }()
        
        let subtitle = data.shelterName
        
        let badges: [BadgeViewData] = [
            BadgeViewData(
                text: data.animalKind.rawValue,
                backgroundColor: .navigationBar,
                textColor: .label
            ),
            BadgeViewData(
                text: data.animalVariety.trimmingCharacters(in: .whitespaces),
                backgroundColor: .navigationBar,
                textColor: .label
            ),
            BadgeViewData(
                text: data.animalSex.displaySexName(),
                backgroundColor: .navigationBar,
                textColor: .label
            ),
            BadgeViewData(
                text: data.animalAge.AgeText(),
                backgroundColor: .navigationBar,
                textColor: .label
            )
        ]
        
        let status = StatusCardViewData(
            statusText: "目前狀態：" + data.animalStatus.statusText(),
            statusBackgroundColor: data.animalStatus.backgroundColor(),
            statusTextColor: data.animalStatus.textColor(),
            openDateText: makeDataText(from: data.animalOpendate),
            updateDateText: makeDataText(from: data.animalUpdate)
        )
        
        let leftInfoRows: [InfoRowViewData] = [
            InfoRowViewData(title: "類型", value: data.animalKind.rawValue),
            InfoRowViewData(title: "品種", value: data.animalVariety.trimmingCharacters(in: .whitespaces)),
            InfoRowViewData(title: "性別", value: data.animalSex.displaySexName()),
            InfoRowViewData(title: "年紀", value: data.animalAge.AgeText()),
        ]
        
        let rightInfoRows: [InfoRowViewData] = [
            InfoRowViewData(title: "體型", value: data.animalBodytype.BodyTypeText()),
            InfoRowViewData(title: "毛色", value: data.animalColour),
            InfoRowViewData(title: "絕育狀況", value: data.animalSterilization.sterilizationText()),
            InfoRowViewData(title: "狂犬病疫苗", value: data.animalBacterin.statusText())
        ]
        
        let info = InfoCardViewData(
            leftInfoRows: leftInfoRows,
            rightInfoRows: rightInfoRows
        )
        
        let shelter = ShelterCardViewData(
            name: data.shelterName,
            adderss: data.shelterAddress,
            phone: data.shelterTel
        )
        
        let note = NoteCardViewData(
            foundPlace: data.animalFoundplace,
            remark: data.animalRemark,
            updateDateText: makeDataText(from: data.cDate)
        )
        
        return PetInformationViewData(
            image: defaultImage,
            title: title,
            subtitle: subtitle,
            badges: badges,
            status: status,
            info: info,
            shelter: shelter,
            note: note
        )
        
    }
    
    func makeDataText(from date: Date?) -> String? {
        guard let date, date != Date.distantPast else { return nil }
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Image Download
    /// 下載圖片
    func loadImageIfNeeded() {
        guard let url = URL(string: petData.albumFile) else { return }
        isImageLoading = true
        
        // 使用 imageKit 載處理過後的圖
        imageLoader.loadFromImageKit(from: url, imageSizeType: .detail)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.viewData?.image = image
                self?.isImageLoading = false
            }
            .store(in: &cancellables)
    }

}
