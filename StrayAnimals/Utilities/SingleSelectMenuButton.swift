//
//  SingleSelectMenuButton.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/9/2.
//

import UIKit

/// Item Model
struct SingleSelectItem: Hashable {
    let id: String
    let title: String
}

class SingleSelectMenuButton: UIButton {
    /// 還沒選擇前的文字
    private let defaultTitle: String
    /// Menu 固定最上方顯示的文字
    private let menuTitle: String
    
    /// Menu 內有的 Item
    var items: [SingleSelectItem] = [] {
        didSet {
            rebuildMenu()
        }
    }
    /// 已選擇的 Item
    var selectedItem: SingleSelectItem? {
        didSet {
            updateAppearance()
            rebuildMenu()
        }
    }
    /// 選擇後觸發的 action
    var onSelectionChanged: ((SingleSelectItem) -> Void)?
    
    // MARK: - method
    
    init(defaultTitle: String,
         menuTitle: String,
         items: [SingleSelectItem] = []
    ) {
        self.defaultTitle = defaultTitle
        self.menuTitle = menuTitle
        self.items = items
        
        super.init(frame: .zero)
        
        setupUI()
        rebuildMenu()
    }

    
    required init?(coder: NSCoder) {
        fatalError("SingleSelectMenuButton init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 點擊 button 直接顯示 menu
        showsMenuAsPrimaryAction = true
        
        contentHorizontalAlignment = .leading
        
        var configuration = UIButton.Configuration.plain()
        // 設定圖片
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8
        configuration.contentInsets = .init(
            top: 10,
            leading: 8,
            bottom: 10,
            trailing: 8
        )
        configuration.image = UIImage.more.resized(to: CGSize(width: 16, height: 16))
        // 讓圖片貼著按鈕右邊
        contentHorizontalAlignment = .fill
        // 圓角、邊框、背景色
        configuration.background.cornerRadius = 8
        configuration.background.strokeWidth = 1
        configuration.background.strokeColor = .black
        configuration.background.backgroundColor = .white
        // 文字
        configuration.title = defaultTitle
        configuration.titleAlignment = .leading
        configuration.baseForegroundColor = .label
        configuration.titleTextAttributesTransformer =
        UIConfigurationTextAttributesTransformer({ incoming in
            var output = incoming
            output.font = FontGroup.font(.medium, .small)
            return output
        })
        self.configuration = configuration
    }
    
}

private extension SingleSelectMenuButton {
    /// 轉換 Item 成 Menu 的物件
    func rebuildMenu() {
        let actions = items.map { [weak self] item in
            
            UIAction(
                title: item.title,
                state: item == self?.selectedItem ? .on : .off
            ) { [weak self] _ in
                self?.select(item)
            }
        }
        
        menu = UIMenu(title: menuTitle, options: .singleSelection ,children: actions)
    }
    /// 選擇
    func select(_ item: SingleSelectItem) {
        // 點擊曾經選過的選項為「取消選擇」
        if selectedItem == item {
            selectedItem = nil
        } else {
            selectedItem = item
        }
        
        onSelectionChanged?(item)
        
        sendActions(for: .valueChanged)
    }
    
    /// 選擇後更新 UI
    func updateAppearance() {
        configuration?.title = selectedItem?.title ?? defaultTitle
    }
}
