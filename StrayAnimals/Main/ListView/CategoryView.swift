//
//  CategoryView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/9/3.
//

import UIKit
final class CategoryView: UIView {
    
    private let scrollView = UIScrollView()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
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
        menuButtons.append(SingleSelectMenuButton(defaultTitle: "種類", menuTitle: "請選擇種類", items: kindItems))
        
        // 性別（撇除未知）
        let sexItems = AnimalSex.allCases
            .filter { $0 != .unknown }
            .map { SingleSelectItem(id: $0.rawValue, title: $0.displaySexName()) }
        menuButtons.append(SingleSelectMenuButton(defaultTitle: "性別", menuTitle: "請選擇性別", items: sexItems))

        // 年紀（撇除未知）
        let ageItems = AnimalAge.allCases
            .filter { $0 != .unknown }
            .map { SingleSelectItem(id: $0.rawValue, title: $0.AgeText()) }
        menuButtons.append(SingleSelectMenuButton(defaultTitle: "年紀", menuTitle: "請選擇年紀", items: ageItems))
        
        // 體型（撇除未知）
        let bodyTypeItems = AnimalBodyType.allCases
            .filter { $0 != .unknown }
            .map { SingleSelectItem(id: $0.rawValue, title: $0.BodyTypeText()) }
        menuButtons.append(SingleSelectMenuButton(defaultTitle: "體型", menuTitle: "請選擇體型", items: bodyTypeItems))
        
        // 地區（撇除未知）
        let areaItems = TaiwanArea.allCases
            .filter { $0 != .unknown }
            .map { SingleSelectItem(id: "\($0.rawValue)", title: $0.areaName()) }
        menuButtons.append(SingleSelectMenuButton(defaultTitle: "地區", menuTitle: "請選擇地區", items: areaItems))
        
        menuButtons.forEach { contentStackView.addArrangedSubview($0) }
    }
    
}
