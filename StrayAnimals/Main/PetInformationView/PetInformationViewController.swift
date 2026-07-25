//
//  PetInformationViewController.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/3/26.
//

import UIKit
import SnapKit
import Combine
import MapKit
import Contacts

final class PetInformationViewController: UIViewController {
    // MARK: - UI
    private let scrollView: UIScrollView = UIScrollView()
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
        
        scrollView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.height.lessThanOrEqualTo(imageView.snp.width)
        }
        
        scrollView.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }
        
        scrollView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.left.right.bottom.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
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
            }
            .store(in: &cancellables)
        
    }
    
    private func bindAction() {
        // 點擊打開地圖
        shelterCardView.bottomButtonView.leftButtonOnTap = { [weak self] sender in
            guard let self,
                  let address = self.viewModel.makeMapAddress()
            else { return }
            let placemark = MKPlacemark(coordinate: .init(), addressDictionary: [CNPostalAddressStreetKey: address])
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = address
            mapItem.openInMaps()
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
            self.showShareActivityVC(
                items: self.viewModel.makeShareItems(),
                sourceView: sender
            )
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
    
}
