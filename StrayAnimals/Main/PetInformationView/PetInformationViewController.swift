//
//  PetInformationViewController.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/3/26.
//

import UIKit
import SnapKit
import Combine

final class PetInformationViewController: UIViewController {
    // MARK: - UI
    private let scrollView: UIScrollView = UIScrollView()
    private let contentView: UIView = UIView()
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let loadingView: LoadingView
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let summartCardView = SummaryCardView()
    private let statusCardView = StatusCardView()
    private let infoCardView = InfoCardView()
    private let shelterCardView = ShelterCardView()
    private let noteCardView = NoteCardView()
    private let bottomActionView = BottomActionView()
    
    // MARK: - property
    private let viewModel: PetInformationViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - method
    init(viewModel: PetInformationViewModel) {
        self.viewModel = viewModel
        self.loadingView = .init(style: .large)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("PetInformationViewController init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindViewModel()
        bindAction()
        viewModel.viewDidLoad()
    }
        
    private func setUI() {
        view.backgroundColor = .viewBackground
        title = "詳細資料"
        
        view.addSubview(bottomActionView)
        bottomActionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.1)
        }
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomActionView.snp.top)
        }
        
        scrollView.addSubview(contentView)
        contentView.backgroundColor = .viewBackground
        contentView.snp.makeConstraints { make in
            // 四邊跟 scrollView 的可捲動內容範圍一樣
            make.edges.equalTo(scrollView.contentLayoutGuide)
            // 寬度跟捲動視圖看得見的外框大小一樣
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.lessThanOrEqualTo(imageView.snp.width)
        }
        
        contentView.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }
        
        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        contentStackView.addArrangedSubview(summartCardView)
        contentStackView.addArrangedSubview(statusCardView)
        contentStackView.addArrangedSubview(infoCardView)
        contentStackView.addArrangedSubview(shelterCardView)
        contentStackView.addArrangedSubview(noteCardView)
    }
    
    private func bindViewModel() {
        viewModel.$viewData
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewData in
                self?.render(viewData)
            }
            .store(in: &cancellables)
        
        viewModel.$isImageLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
                // 圖片還在下載，不可以點擊分享按鈕
                self?.bottomActionView.setLeftButtonEnable(!isLoading)
            }
            .store(in: &cancellables)
        
    }
    
    private func bindAction() {
        // 點擊打開地圖
        shelterCardView.bottomButtonView.leftButtonOnTap = { [weak self] sender in
            guard let self,
                  let url = self.viewModel.makeMapURL(),
                  UIApplication.shared.canOpenURL(url)
            else { return }

            UIApplication.shared.open(url)
        }
        // 點擊撥打電話
        shelterCardView.bottomButtonView.rightButtonOnTap = { [weak self] sender in
            guard let self,
                  let url = self.viewModel.makeCallURL(),
                  UIApplication.shared.canOpenURL(url)
            else { return }
            
            UIApplication.shared.open(url)
        }
        
        // 點擊分享
        bottomActionView.leftButtonOnTap = { [weak self] sender in
            guard let self else { return }
            self.showLoadingView()
            // 先讓 Loading View 顯示出來，再開始產生分享圖片
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self else { return }
                // 確保畫面還在，才要繼續截圖分享
                guard self.view.window != nil,
                      let image = self.makeShareImage() else {
                    self.hideLoadingView()
                    return
                }
                self.showShareActivityVC(
                    items: [image],
                    sourceView: sender,
                    completion: {
                        self.hideLoadingView()
                    }
                )
            }
        }
        // 點擊撥打電話
        bottomActionView.rightButtonOnTap = { [weak self] sender in
            guard let self,
                  let url = self.viewModel.makeCallURL(),
                  UIApplication.shared.canOpenURL(url)
            else { return }
            
            UIApplication.shared.open(url)
        }
    }
    
    private func render(_ viewData: PetInformationViewData) {
        
        imageView.image = viewData.image
        
        summartCardView.configure(
            title: viewData.title,
            subtitle: viewData.subtitle,
            badges: viewData.badges
        )
        
        statusCardView.configure(with: viewData.status)
        
        infoCardView.configure(with: viewData.info)
        
        shelterCardView.configure(with: viewData.shelter)
        
        noteCardView.configure(with: viewData.note)
        
        bottomActionView.configure(
            leftBtn: .outlined(title: "分享", image: UIImage.share),
            rightBtn: .filled(title: "聯絡收容所", image: UIImage.phone),
            stackViewDistribution: .fillProportionally
        )
        bottomActionView.backgroundColor = .white
        
    }
    
    /// 將此頁面變成一張截圖
    private func makeShareImage() -> UIImage? {
        // 先更新 view 的狀態
        view.layoutIfNeeded()
        contentView.layoutIfNeeded()
        // 使用 Scroll View 裡的 Content View 製作，防止使用 Scroll View 只截取到部分畫面
        let size = contentView.bounds.size
        // 防呆：尺寸不正常就不產生圖片
        guard size.width > 0, size.height > 0 else { return nil }
        
        // 設定圖片渲染格式
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale
        // 圖片不需要透明背景
        format.opaque = true
        
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            contentView.drawHierarchy(
                in: CGRect(origin: .zero, size: size),
                afterScreenUpdates: true
            )
        }
    }
}
