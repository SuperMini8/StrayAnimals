
import UIKit

extension UIViewController {
    //MARK: - Alert
    /// 顯示 Alert
    func showAlert(title: String? = "",
                   message: String?,
                   buttonTitle: String,
                   buttonStyle: UIAlertAction.Style = .default,
                   buttonAction:((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let button = UIAlertAction(title: buttonTitle, style: buttonStyle, handler: buttonAction)
        alert.addAction(button)
        present(alert, animated: true)
    }
    // MARK: - Share Activity View Controller
    /// 顯示「分享」畫面
    func showShareActivityVC(items: [Any],
                             activities: [UIActivity]? = nil,
                             sourceView: UIView? = nil,
                             sourceRect: CGRect? = nil,
                             completion: (() -> Void)? = nil) {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: activities)
        // iPad 需要先設定 sourceView 與 sourceRect
        let anchorView: UIView = sourceView ?? view
        controller.popoverPresentationController?.sourceView = anchorView
        controller.popoverPresentationController?.sourceRect = sourceRect ?? anchorView.bounds
        present(controller, animated: true, completion: completion)
    }
    //MARK: - Loading View
    /// 顯示 Loading View
    func showLoadingView() {
        let loadingView: LoadingView
        /// 先尋找是否已有 LoadingView 決定是否要加入新的
        if let originalLV = view.subviews.first(where: { $0 is LoadingView }) as? LoadingView  {
            loadingView = originalLV
        } else {
            loadingView = LoadingView(style: .large)
            view.addSubview(loadingView)
            loadingView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        loadingView.startAnimating()
    }
    /// 關閉 LoadingView
    func hideLoadingView() {
        if let loadingView = view.subviews.first(where: { $0 is LoadingView }) as? LoadingView {
            loadingView.stopAnimating()
            loadingView.removeFromSuperview()
        }
    }
    // MARK: - Window & Scene
    var currentWindow: UIWindow? {
        return view.window
    }
    var currentWindowScene: UIWindowScene? {
        return view.window?.windowScene
    }
    var currentScreen: UIScreen? {
        return view.window?.windowScene?.screen
    }
}
