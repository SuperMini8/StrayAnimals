
import UIKit

extension UIViewController {
    
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
    
    func showLoadingView() {
        let loadingView = LoadingView()
        if !view.subviews.contains(loadingView) {
            view.addSubview(loadingView)
            loadingView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        loadingView.startAnimating()
    }
    
    func hideLoadingView() {
        if let loadingView = view.subviews.first(where: { $0 is LoadingView }) as? LoadingView {
            loadingView.stopAnimating()
            loadingView.removeFromSuperview()
        }
    }
    
}
