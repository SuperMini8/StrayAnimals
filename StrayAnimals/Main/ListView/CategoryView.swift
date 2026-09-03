//
//  CategoryView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/9/3.
//

import UIKit
import SnapKit

protocol SingleSelectable: CaseIterable {
    var selectID: String { get }
    var selectTitle: String { get }
    var isSelectable: Bool { get }
}

extension AnimalKind: SingleSelectable {
    var selectID: String { self.rawValue }
    var selectTitle: String { self.rawValue }
    var isSelectable: Bool { true }
}

extension AnimalSex: SingleSelectable {
    var selectID: String { self.rawValue }
    var selectTitle: String { self.displaySexName() }
    var isSelectable: Bool { self != .unknown }
}

extension AnimalAge: SingleSelectable {
    var selectID: String { self.rawValue }
    var selectTitle: String { self.ageText() }
    var isSelectable: Bool { self != .unknown }
}

extension AnimalBodyType: SingleSelectable {
    var selectID: String { self.rawValue }
    var selectTitle: String { self.bodyTypeText() }
    var isSelectable: Bool { self != .unknown }
}

extension TaiwanArea: SingleSelectable {
    var selectID: String { String(self.rawValue) }
    var selectTitle: String { self.areaName() }
    var isSelectable: Bool { self != .unknown }
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
        // 種類
        addMenuButton(defaultTitle: "種類",
                      menuTitle: "請選擇種類",
                      type: AnimalKind.self) { [weak self] kind in
            self?.currentFilter.kind = kind
        }
        // 性別
        addMenuButton(defaultTitle: "性別",
                      menuTitle: "請選擇性別",
                      type: AnimalSex.self) { [weak self] sex in
            self?.currentFilter.sex = sex
        }
        // 年紀（撇除未知）
        addMenuButton(defaultTitle: "年紀",
                      menuTitle: "請選擇年紀",
                      type: AnimalAge.self) { [weak self] age in
            self?.currentFilter.age = age
        }
        // 體型（撇除未知）
        addMenuButton(defaultTitle: "體型",
                      menuTitle: "請選擇體型",
                      type: AnimalBodyType.self) { [weak self] body in
            self?.currentFilter.bodyType = body
        }
        // 地區（撇除未知）
        addMenuButton(defaultTitle: "地區",
                      menuTitle: "請選擇地區",
                      type: TaiwanArea.self) { [weak self] area in
            self?.currentFilter.area = area
        }
    }
    // 將 SingleSelectable 的 enum 變成 menuButton 並且加入至 stack view
    private func addMenuButton<Option>(
        defaultTitle: String,
        menuTitle: String,
        type: Option.Type,
        onSelectionChanged: @escaping (Option?) -> Void
    ) where Option: SingleSelectable {
        
        let options = Option.allCases.filter { $0.isSelectable }
        let items = options.map { SingleSelectItem(id: $0.selectID, title: $0.selectTitle) }
        let button = SingleSelectMenuButton(defaultTitle: defaultTitle, menuTitle: menuTitle, items: items)
        button.onSelectionChanged = { [weak self] item in
            // 在這裡先比對相同 id
            let option = item.flatMap { i in
                options.first { $0.selectID == i.id }
            }
            onSelectionChanged(option)
            self?.sendFilterChanged()
        }
        contentStackView.addArrangedSubview(button)
    }

    private func sendFilterChanged() {
        onFilterChanged?(currentFilter)
    }
    
}
