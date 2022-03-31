import UIKit

class HomeViewController: UIViewController {

    // MARK: Internal Types

    typealias BlurStyle = UIBlurEffect.Style

    // MARK: - Private Properties

    @IBOutlet private weak var backgroundImageView: UIImageView!
    private var blurEffectView: UIVisualEffectView?
    private var selectedImageIndex = 0
    private var imagePicker = UIImagePickerController()
    private var editImage: UIImage?

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self

        applyBlur()
        configureNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        selectedImageIndex = Int.random(in: 1...11)
        backgroundImageView.image = UIImage(named: String(describing: selectedImageIndex))
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        blurEffectView?.frame = view.bounds
    }

    // MARK: - Internal Methods

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddFilerToPhotoSegue" {
            guard let destination = segue.destination as? PhotoEditorViewController else {
                return
            }
            destination.editImage = editImage
        }
    }

    // MARK: - Private Methods

    @IBAction private func takeFromCameraPressed() {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction private func takeFromGalleryPressed() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    private func configureNavigationBar() {
        let attrs = [
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 20)!
        ]
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = attrs
        appearance.backgroundColor = .clear
        appearance.backgroundImage = UIImage(color: UIColor(named: "BackgroundColor1")!)

        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.backgroundColor = appearance.backgroundColor
    }

    private func applyBlur() {
        let style: BlurStyle = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        let blurEffect = UIBlurEffect(style: style)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView!)
    }

}

// MARK: - Helper

extension UIImage {

    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            editImage = image
        }

        dismiss(animated: true, completion: {[weak self] in
            self?.performSegue(withIdentifier: "AddFilerToPhotoSegue", sender: nil)
        })
    }
}
