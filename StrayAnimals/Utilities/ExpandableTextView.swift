//
//  ExpandableTextView.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/9/7.
//

import UIKit
import SnapKit

/// 始終顯示完整文字，依指定行數或參考文字的高度裁切收合內容。
///
/// 收合時是「切齊指定行數的下緣」，**不會出現 `...`**：`textLabel` 的
/// `numberOfLines` 永遠是 0，靠 `textContainerView` 的 `clipsToBounds` 裁切。
/// 換到的是展開／收合時文字不需重排，高度動畫平滑。需要省略號的話這個做法不適用，
///
/// 放在 `UITableViewCell` 裡使用時，請在 `onExpandedChanged` 內觸發 table 重算高度
/// （`beginUpdates()` / `endUpdates()` 或 `performBatchUpdates`），否則 cell 高度
/// 不會跟著變。cell 重用時展開狀態要由外部持有，透過 `setText(_:expanded:)` 帶回。
final class ExpandableTextView: UIView {

    /// 裁切方式
    private enum CollapseMode {
        /// 限制行數
        case lines(Int)
        /// 限制文字內容
        case customText
    }

    // MARK: - UI

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 2
        return stackView
    }()

    /// 顯示文字用
    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        // numberOfLines 為 0 時不會實際截斷，但 textRect(forBounds:limitedToNumberOfLines:)
        // 會依這個模式計算收合高度。
        label.lineBreakMode = .byTruncatingTail
        label.font = FontGroup.font(.regular, .small)
        label.textColor = .black
        return label
    }()

    /// 僅供測量收合高度，不加入畫面。
    private let measurementLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    /// 用 clipsToBounds 來裁切文字
    private let textContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()

    /// 「顯示更多」與「顯示更少」的按鈕。
    ///
    /// 用 `UIButton.Configuration` 是為了把圖示排在文字右邊（`imagePlacement = .trailing`），
    /// 傳統的 `imageEdgeInsets` 在 iOS 15 已標記 deprecated。
    private let toggleButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.contentInsets = .zero
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 4

        let button = UIButton(configuration: configuration)
        button.contentHorizontalAlignment = .trailing
        return button
    }()

    // MARK: - Public

    /// 內文字體，變更後會重新測量
    var font: UIFont {
        get { textLabel.font }
        set {
            textLabel.font = newValue
            invalidateMeasurement()
        }
    }

    /// 內文顏色
    var textColor: UIColor {
        get { textLabel.textColor }
        set { textLabel.textColor = newValue }
    }

    /// 內文對齊方式
    var textAlignment: NSTextAlignment {
        get { textLabel.textAlignment }
        set { textLabel.textAlignment = newValue }
    }

    /// 展開／收合按鈕的字體
    var buttonFont: UIFont = FontGroup.font(.regular, .small) {
        didSet {
            updateToggleButton()
        }
    }

    /// 展開／收合按鈕的文字顏色。圖示若是 template 也會跟著上色。
    var buttonTitleColor: UIColor = .statusNormalText {
        didSet {
            updateToggleButton()
        }
    }

    /// 收合狀態下按鈕右側的圖示，設 `nil` 就不顯示
    var moreImage: UIImage? = .more {
        didSet {
            updateToggleButton()
        }
    }

    /// 展開狀態下按鈕右側的圖示，設 `nil` 就不顯示
    var lessImage: UIImage? = .less {
        didSet {
            updateToggleButton()
        }
    }

    /// 按鈕文字與圖示之間的間距
    var buttonImagePadding: CGFloat {
        get { toggleButton.configuration?.imagePadding ?? 0 }
        set { toggleButton.configuration?.imagePadding = newValue }
    }

    /// 展開／收合按鈕的水平對齊，預設靠右
    var buttonHorizontalAlignment: UIControl.ContentHorizontalAlignment {
        get { toggleButton.contentHorizontalAlignment }
        set { toggleButton.contentHorizontalAlignment = newValue }
    }

    /// 文字與按鈕的間距
    var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }

    /// 內容四周的內距，預設為 0。變更後會重新測量（可用寬度會跟著變）。
    var contentInsets: UIEdgeInsets {
        get { stackView.layoutMargins }
        set {
            stackView.layoutMargins = newValue
            invalidateMeasurement()
        }
    }

    var moreTitle: String = "顯示更多" {
        didSet {
            updateToggleButton()
        }
    }

    var lessTitle: String = "顯示更少" {
        didSet {
            updateToggleButton()
        }
    }

    /// 是否展開。
    ///
    /// 文字短到不需要收合時固定為 `false`（使用者沒有展開過），此時畫面本來就是完整內容。
    /// 要判斷「有沒有被裁切」使用 `isTruncatable`。
    private(set) var isExpanded = false

    /// 內容是否超過收合高度，也就是展開按鈕是否顯示中。
    var isTruncatable: Bool { needsExpansion }

    /// 透過 setExpanded 改變狀態時呼叫，於動畫開始前通知。
    /// 設定文字或測量時重設狀態不會觸發。
    var onExpandedChanged: ((Bool) -> Void)?

    // MARK: - Private

    private var textContainerHeightConstraint: Constraint?

    private var collapsedHeight: CGFloat = 0
    private var expandedHeight: CGFloat = 0

    private var lastMeasuredWidth: CGFloat = 0

    private var collapseMode: CollapseMode = .lines(3)
    private var fullText = NSAttributedString(string: "")
    private var collapsedText = NSAttributedString(string: "")
    private var needsExpansion = false

    private var hasText: Bool { fullText.length > 0 }

    /// 扣掉左右內距後，文字實際可用的寬度。測量一律以這個寬度為準。
    private var textWidth: CGFloat {
        max(0, bounds.width - contentInsets.left - contentInsets.right)
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        addSubview(stackView)
        stackView.addArrangedSubview(textContainerView)
        stackView.addArrangedSubview(toggleButton)
        textContainerView.addSubview(textLabel)

        stackView.isLayoutMarginsRelativeArrangement = true
        // UIView 的 layoutMargins 預設是 8，這裡歸零讓 layoutMargins 的預設維持 0。
        stackView.layoutMargins = .zero
        // 元件貼齊螢幕邊緣時不要再多吃 safe area，內距一律由 contentInsets 決定。
        stackView.insetsLayoutMarginsFromSafeArea = false
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        textContainerView.snp.makeConstraints { make in
            textContainerHeightConstraint = make.height.equalTo(0).constraint
        }
        
        textLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            // 不約束 bottom，讓 label 保持完整高度，由容器裁切收合內容。
        }

        toggleButton.addTarget(
            self,
            action: #selector(didTapToggle),
            for: .touchUpInside
        )

        toggleButton.isHidden = true
        updateToggleButton()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        // Stack view 尚未排版時，文字容器寬度可能為 0；使用自身 bounds 扣掉內距後的寬度。
        let width = textWidth

        guard width > 0, hasText else {
            return
        }

        // 避免每次 layout 都重新計算
        guard
            abs(width - lastMeasuredWidth) > 0.5 ||
                expandedHeight == 0
        else {
            return
        }

        lastMeasuredWidth = width

        updateTextMeasurement(width: width)
    }

    // MARK: - Measurement

    private func updateTextMeasurement(width: CGFloat) {
        guard hasText else {
            resetMeasurement()
            return
        }

        // 完整文字高度
        let fittingSize = CGSize(
            width: width,
            height: CGFloat.greatestFiniteMagnitude
        )

        expandedHeight = ceil(textLabel.sizeThatFits(fittingSize).height)

        // 指定行數時的高度
        let bounds = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: CGFloat.greatestFiniteMagnitude
        )

        switch collapseMode {
        case let .lines(count):
            collapsedHeight = ceil(textLabel.textRect(
                forBounds: bounds,
                limitedToNumberOfLines: max(0, count)
            ).height)

        case .customText:
            measurementLabel.font = textLabel.font
            measurementLabel.textAlignment = textLabel.textAlignment
            measurementLabel.lineBreakMode = textLabel.lineBreakMode
            measurementLabel.attributedText = collapsedText
            collapsedHeight = collapsedText.length == 0
                ? 0 : ceil(measurementLabel.sizeThatFits(fittingSize).height)
        }

        // 參考文字只決定高度，收合高度不超過全文高度。
        collapsedHeight = min(collapsedHeight, expandedHeight)
        needsExpansion = expandedHeight > collapsedHeight + 0.5
        toggleButton.isHidden = !needsExpansion

        if needsExpansion {

            let targetHeight = isExpanded ? expandedHeight : collapsedHeight
            textContainerHeightConstraint?.update(offset: targetHeight)

        } else {
            // 不需要切換時，統一使用收合狀態。
            isExpanded = false

            textContainerHeightConstraint?.update(offset: expandedHeight)
        }

        updateToggleButton()
    }

    /// 沒有文字時把測量結果與畫面一起歸零。
    private func resetMeasurement() {
        collapsedHeight = 0
        expandedHeight = 0
        isExpanded = false
        needsExpansion = false

        textContainerHeightConstraint?.update(offset: 0)
        toggleButton.isHidden = true
        updateToggleButton()
    }

    // MARK: - Action

    @objc
    private func didTapToggle() {
        setExpanded(!isExpanded, animated: true)
    }

    // MARK: - Public Methods

    /// 依行數收合；0 表示不限行數，負數視為 0。
    func setText(
        _ text: String?,
        collapsedNumberOfLines: Int = 3,
        expanded: Bool = false
    ) {
        setAttributedText(
            text.map { NSAttributedString(string: $0) },
            collapsedNumberOfLines: collapsedNumberOfLines,
            expanded: expanded
        )
    }

    /// collapsedText 僅用於測量收合高度；畫面始終顯示完整文字。
    func setText(
        _ text: String?,
        collapsedText: String?,
        expanded: Bool = false
    ) {
        setAttributedText(
            text.map { NSAttributedString(string: $0) },
            collapsedText: collapsedText.map { NSAttributedString(string: $0) },
            expanded: expanded
        )
    }

    /// 依行數收合並保留文字格式；0 表示不限行數，負數視為 0。
    func setAttributedText(
        _ attributedText: NSAttributedString?,
        collapsedNumberOfLines: Int = 3,
        expanded: Bool = false
    ) {
        configure(
            fullText: attributedText,
            collapsedText: attributedText,
            mode: .lines(max(0, collapsedNumberOfLines)),
            expanded: expanded
        )
    }

    /// 依 collapsedText 的文字格式測量收合高度；畫面始終顯示完整版。
    /// nil 視為空文字，收合高度為 0。
    func setAttributedText(
        _ attributedText: NSAttributedString?,
        collapsedText: NSAttributedString?,
        expanded: Bool = false
    ) {
        configure(
            fullText: attributedText,
            collapsedText: collapsedText,
            mode: .customText,
            expanded: expanded
        )
    }

    func setExpanded(_ expanded: Bool, animated: Bool) {
        let animationView = animationContainer()

        // 先完成目前的 layout，讓高度動畫從現有 frame 開始。
        animationView.layoutIfNeeded()

        // 先依最新文字與寬度測量，不依賴按鈕上一次的顯示狀態。
        if hasText, textWidth > 0 {
            updateTextMeasurement(width: textWidth)
            animationView.layoutIfNeeded()
        }

        let canExpand = hasText && (textWidth <= 0 || needsExpansion)
        let targetExpanded = expanded && canExpand
        guard isExpanded != targetExpanded else { return }

        isExpanded = targetExpanded

        // 尚無可測量的寬度時，保留要求的狀態，等首次排版再套用高度。
        guard textWidth > 0 else {
            updateToggleButton()
            setNeedsLayout()
            onExpandedChanged?(targetExpanded)
            return
        }

        let targetHeight = targetExpanded ? expandedHeight : collapsedHeight

        textContainerHeightConstraint?.update(offset: targetHeight) 

        updateToggleButton()
        onExpandedChanged?(targetExpanded)

        guard animated else {
            animationView.layoutIfNeeded()
            return
        }

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            options: [
                .curveEaseInOut,
                .beginFromCurrentState,
                .allowUserInteraction
            ]
        ) {
            animationView.layoutIfNeeded()
        }
    }

    // MARK: - Private

    private func configure(
        fullText: NSAttributedString?,
        collapsedText: NSAttributedString?,
        mode: CollapseMode,
        expanded: Bool
    ) {
        self.fullText = fullText.map { NSAttributedString(attributedString: $0) }
            ?? NSAttributedString(string: "")
        self.collapsedText = collapsedText.map { NSAttributedString(attributedString: $0) }
            ?? NSAttributedString(string: "")
        textLabel.attributedText = self.fullText
        collapseMode = mode
        isExpanded = expanded && hasText

        guard hasText else {
            // 沒有文字時不會進 layoutSubviews 的測量流程，直接歸零。
            resetMeasurement()
            return
        }

        updateToggleButton()
        invalidateMeasurement()
    }

    private func invalidateMeasurement() {
        lastMeasuredWidth = 0
        collapsedHeight = 0
        expandedHeight = 0

        setNeedsLayout()
    }

    private func updateToggleButton() {
        var configuration = toggleButton.configuration ?? .plain()

        let title = NSAttributedString(
            string: isExpanded ? lessTitle : moreTitle,
            attributes: [
                .font: buttonFont,
                .foregroundColor: buttonTitleColor
            ]
        )
        configuration.attributedTitle = AttributedString(title)
        configuration.image = isExpanded ? lessImage : moreImage
        // template 圖示才會吃這個顏色，一般的彩色 png 維持原樣。
        configuration.baseForegroundColor = buttonTitleColor

        toggleButton.configuration = configuration
    }
    /// 找到能涵蓋 scroll view 捲動位置修正的那一層。
    ///
    /// 收合時若 scroll view 已捲到下方，UIKit 會強制把 contentOffset 拉回可捲範圍。
    /// 這個修正只有在「包住 scroll view 的那一層」做 layoutIfNeeded 才會被納入動畫，
    /// 否則會在動畫之外瞬間跳掉。
    private func animationContainer() -> UIView {
        var candidate: UIView? = self
        while let view = candidate {
            if let scrollView = view as? UIScrollView {
                return scrollView.superview ?? scrollView
            }
            candidate = view.superview
        }
        return superview ?? self
    }
}
