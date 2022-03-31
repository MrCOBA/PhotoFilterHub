import UIKit

class LoadingViewController: UIViewController {

    // MARK: Internal Types

    typealias BlurStyle = UIBlurEffect.Style

    // MARK: - Internal Properties

    var loadingActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()

        indicator.style = .large
        indicator.color = .label
        indicator.startAnimating()

        indicator.autoresizingMask = [
            .flexibleLeftMargin, .flexibleRightMargin,
            .flexibleTopMargin, .flexibleBottomMargin
        ]

        return indicator
    }()

    var blurEffectView: UIVisualEffectView = {
        let style: BlurStyle = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)

        blurEffectView.alpha = 0.8

        blurEffectView.autoresizingMask = [
            .flexibleWidth, .flexibleHeight
        ]

        return blurEffectView
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        blurEffectView.frame = self.view.bounds
        view.insertSubview(blurEffectView, at: 0)

        loadingActivityIndicator.center = CGPoint(
            x: view.bounds.midX,
            y: view.bounds.midY
        )
        view.addSubview(loadingActivityIndicator)
    }

}
