//
//  CategoryView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/9/3.
//

import UIKit
import SnapKit
/// 類別傳送資料用
struct AnimalListFilter: Equatable {
    var kind: AnimalKind?
    var sex: AnimalSex?
    var age: AnimalAge?
    var bodyType: AnimalBodyType?
    var area: TaiwanArea?
    var variety: String?
}

final class CategoryView: UIView {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        stackView.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    var onFilterChanged: ((AnimalListFilter) -> Void)?
    /// 紀錄目前所有選擇狀態
    private var currentFilter = AnimalListFilter()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("CategoryView init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        scrollView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            // 四邊跟 scrollView 的可捲動內容範圍一樣
            make.edges.equalTo(scrollView.contentLayoutGuide)
            // 高度跟捲動視圖看得見的外框大小一樣
            make.height.equalTo(scrollView.frameLayoutGuide)
        }

    }
    
    private func setContent() {
        var menuButtons: [SingleSelectMenuButton] = []
        // 種類
        let kindItems = AnimalKind.allCases.map { SingleSelectItem(id: $0.rawValue, title: $0.rawValue) }
        let kindButton = SingleSelectMenuButton(defaultTitle: "種類", menuTitle: "請選擇種類", items: kindItems)
        kindButton.onSelectionChanged = { [weak self] item in
            self?.currentFilter.kind = item.flatMap { AnimalKind(rawValue: $0.id) }
            self?.sendFilterChanged()
        }
        menuButtons.append(kindButton)
        
        // 性別（撇除未知）
        let sexItems = AnimalSex.allCases
            .filter { $0 != .unknown }
            .map { SingleSelectItem(id: $0.rawValue, title: $0.displaySexName()) }
        let sexButton = SingleSelectMenuButton(defaultTitle: "性別", menuTitle: "請選擇性別", items: sexItems)
        sexButton.onSelectionChanged = { [weak self] item in
            self?.currentFilter.sex = item.flatMap { AnimalSex(rawValue: $0.id) }
            self?.sendFilterChanged()
        }
        menuButtons.append(sexButton)

        // 年紀（撇除未知）
        let ageItems = AnimalAge.allCases
            .filter { $0 != .unknown }
            .map { SingleSelectItem(id: $0.rawValue, title: $0.AgeText()) }
        let ageButton = SingleSelectMenuButton(defaultTitle: "年紀", menuTitle: "請選擇年紀", items: ageItems)
        ageButton.onSelectionChanged = { [weak self] item in
            self?.currentFilter.age = item.flatMap { AnimalAge(rawValue: $0.id) }
            self?.sendFilterChanged()
        }
        menuButtons.append(ageButton)
        
        // 體型（撇除未知）
        let bodyTypeItems = AnimalBodyType.allCases
            .filter { $0 != .unknown }
            .map { SingleSelectItem(id: $0.rawValue, title: $0.BodyTypeText()) }
        let bodyTypeButton = SingleSelectMenuButton(defaultTitle: "體型", menuTitle: "請選擇體型", items: bodyTypeItems)
        bodyTypeButton.onSelectionChanged = { [weak self] item in
            self?.currentFilter.bodyType = item.flatMap { AnimalBodyType(rawValue: $0.id) }
            self?.sendFilterChanged()
        }
        menuButtons.append(bodyTypeButton)
        
        // 地區（撇除未知）
        let areaItems = TaiwanArea.allCases
            .filter { $0 != .unknown }
            .map { SingleSelectItem(id: "\($0.rawValue)", title: $0.areaName()) }
        let areaButton = SingleSelectMenuButton(defaultTitle: "地區", menuTitle: "請選擇地區", items: areaItems)
        areaButton.onSelectionChanged = { [weak self] item in
            let areaID = item.flatMap { Int($0.id) }
            self?.currentFilter.area = areaID.flatMap { TaiwanArea(rawValue: $0) }
            self?.sendFilterChanged()
        }
        menuButtons.append(areaButton)
        
        menuButtons.forEach { contentStackView.addArrangedSubview($0) }
    }

    private func sendFilterChanged() {
        onFilterChanged?(currentFilter)
    }
    
}
