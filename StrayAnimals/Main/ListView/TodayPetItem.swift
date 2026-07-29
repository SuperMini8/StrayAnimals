//
//  TodayPetItem.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/7/29.
//

import UIKit
import Combine

final class TodayPetItem: UICollectionViewCell {
    // MARK: - UI
    /// 今日更新主要用照片吸引使用者點進詳細頁
    private let animalImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    /// 圖片底部的半透明底，讓地區文字在照片或預設圖上都看得清楚
    private let areaBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        return view
    }()
    /// 今日更新只放一行地區，避免小手機文字太長
    private let areaLabel: UILabel = {
        let label = UILabel()
        label.font = FontGroup.font(.medium, .small)
        label.textColor = .white
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    private lazy var loadingView = LoadingView(style: .medium)
    
    private var viewModel: TodayPetItemViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - method
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("TodayPetItem init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Cell 會重複使用，先取消舊的 image/loading 訂閱，避免舊圖片更新到新 Cell
        cancellables.removeAll()
        animalImageView.image = nil
        areaLabel.text = nil
    }
    
    private func setUI() {
        backgroundColor = .clear
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.border.cgColor
        clipsToBounds = true
        
        if !contentView.contains(animalImageView) {
            contentView.addSubview(animalImageView)
            animalImageView.snp.makeConstraints { make in
                // 圖片填滿整個 TodayCell
                make.top.left.right.bottom.equalToSuperview()
                // 保持正方形，避免橫滑 section 的 cell 高寬跑掉
                make.width.height.equalTo(contentView.snp.width)
            }
        }
        if !contentView.contains(areaBackgroundView) {
            contentView.addSubview(areaBackgroundView)
            areaBackgroundView.snp.makeConstraints { make in
                // 地區文字固定在 Cell 底部，圖片有沒有載到都會顯示
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(32)
            }
        }
        if !areaBackgroundView.contains(areaLabel) {
            areaBackgroundView.addSubview(areaLabel)
            areaLabel.snp.makeConstraints { make in
                // 左右留一點距離，文字太長時用 ... 收尾
                make.left.right.equalToSuperview().inset(8)
                make.centerY.equalToSuperview()
            }
        }
        if !contentView.contains(loadingView) {
            contentView.addSubview(loadingView)
            loadingView.snp.makeConstraints { make in
                make.edges.equalTo(animalImageView)
            }
        }
        // LoadingView 可能會蓋住整張圖片，地區文字要拉到最上層才不會被遮住
        contentView.bringSubviewToFront(areaBackgroundView)
    }
    
    func configure(with viewModel: TodayPetItemViewModel) {
        cancellables.removeAll()
        
        self.viewModel = viewModel
        // 今日更新卡片只顯示一行地區，讓沒有圖片時也知道是哪裡的資料
        areaLabel.text = viewModel.areaName
        
        viewModel.$image
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                // 如果資料沒有照片，就顯示動物種類預設圖
                self?.animalImageView.image = image ?? viewModel.kindImage
            }
            .store(in: &cancellables)
        viewModel.$isImageLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
            }
            .store(in: &cancellables)
        
        startDownloadImage()

    }
    
    // 開始下載圖片
    func startDownloadImage() {
        // 若抓取不到當前的 window 就使用目前裝置 traitCollection
        let scale = window?.windowScene?.screen.scale ?? traitCollection.displayScale
        viewModel?.loadImageIfNeeded(imageSize: .thumbnail, imageScale: scale)
    }
    
}
