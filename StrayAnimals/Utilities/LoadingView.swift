//
//  LoadingView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/3/26.
//

import UIKit
/// 自帶灰色背景的 Loading 動畫的 View，Frame 要給才有顏色背景
final class LoadingView: UIView {
    
    // 需要依賴 init 傳入 style，就不用固定的 property closure 直接初始化，改成在 init 裡建立。
    private let indicator: UIActivityIndicatorView
    
    
    init(frame: CGRect = .zero,
         style: UIActivityIndicatorView.Style
    ) {
        self.indicator = UIActivityIndicatorView(style: style)
        self.indicator.hidesWhenStopped = true
        super.init(frame: frame)
        
        backgroundColor = .viewBackground.withAlphaComponent(0.5)
        
        addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("LoadingView init(coder:) has not been implemented")
    }
    /// 開始動畫
    func startAnimating() {
        isHidden = false
        indicator.startAnimating()
    }
    /// 結束動畫
    func stopAnimating() {
        isHidden = true
        indicator.stopAnimating()
    }
}
