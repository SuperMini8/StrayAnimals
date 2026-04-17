
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
    //MARK: - Loading View
    /// 顯示 Loading View
    func showLoadingView() {
        let loadingView = LoadingView(style: .large)
        if !view.subviews.contains(loadingView) {
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
