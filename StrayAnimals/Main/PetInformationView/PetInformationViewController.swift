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
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.height.equalTo(imageView.snp.width)
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
        
        viewModel.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                self?.handleAction(route)
            }
            .store(in: &cancellables)
    }
    
    private func bindAction() {
        
    }
    
    private func render(_ viewData: PetInformationViewData) {
        
        imageView.image = viewData.image
        
        summartCardView.configure(
            title: viewData.title,
            subtitle: viewData.subtitle,
            badges: viewData.badges
        )
        
        statusCardView.configure(with: viewData.status)
        
    }
    
    private func handleAction(_ route: PetInformationRoute) {
        
    }
}
