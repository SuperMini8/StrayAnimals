//
//  LoadingView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/3/26.
//

import UIKit
/// 自帶灰色背景的 Loading 動畫的 View，Frame 要給才有顏色背景
final class LoadingView: UIView {
    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.lightGrey220.withAlphaComponent(0.5)
        
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
