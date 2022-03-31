import UIKit

class PhotoEditorViewController: UIViewController {

    // MARK: Private Types

    private typealias BlurStyle = UIBlurEffect.Style
    private struct EditorConfiguration {
        var blurEffectView: UIVisualEffectView?
        var selectedImageIndex = 0
        var thumbnailImagesWithFilters: [String : UIImage] = [:]
    }
    
    // MARK: - Private Properties

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var thumbnailPhotosCollectionView: UICollectionView!
    @IBOutlet private weak var backgroundImageView: UIImageView!

    private var configuration: EditorConfiguration = EditorConfiguration()
    private let loadingViewController = LoadingViewController()
    private var currentFilter: Filter = .NoFilters
    private var imageFilter: ImageFilter?

    private let newtworkProcessing = NetworkProcessing(apiURL: "https://filterhub.pythonanywhere.com/images/")

    // MARK: - Internal Properties

    var editImage: UIImage?

    // MARK: - Internal Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        thumbnailPhotosCollectionView.delegate = self
        thumbnailPhotosCollectionView.dataSource = self

        imageView.image = editImage
        applyBlur()
        applyFilters()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configuration.selectedImageIndex = Int.random(in: 1...11)
        backgroundImageView.image = UIImage(named: String(describing: configuration.selectedImageIndex))
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        configuration.blurEffectView?.frame = view.bounds
    }

    // MARK: - Private Methods

    @IBAction private func postButtonPressed() {
        present(makeAlert(), animated: true, completion: nil)
    }

    @objc private func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        hideContentController(content: loadingViewController)
        navigationController?.popToRootViewController(animated: true)
    }

    private func applyBlur() {
        let style: BlurStyle = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        let blurEffect = UIBlurEffect(style: style)
        configuration.blurEffectView = UIVisualEffectView(effect: blurEffect)
        configuration.blurEffectView?.frame = view.bounds
        backgroundImageView.addSubview(configuration.blurEffectView!)
    }

    private func applyFilters() {

        displayContentController(content: loadingViewController)
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .utility)

        for filter in Filter.allCases {
            queue.async(group: group) { [unowned self] in

                guard filter != .NoFilters else {
                    self.configuration.thumbnailImagesWithFilters[filter.identifier] = self.editImage!
                    DispatchQueue.main.async {
                        self.thumbnailPhotosCollectionView.reloadData()
                    }
                    return
                }

                applyThumbnailProcessing(with: filter)
            }
        }

        group.notify(queue: .main, execute: { [unowned self] in
            hideContentController(content: loadingViewController)
        })
    }

    private func displayContentController(content: UIViewController?) {
        guard let content = content else {
            return
        }
        self.navigationController?.addChild(content)
        self.navigationController?.view.addSubview(content.view)
        content.didMove(toParent: self)
    }

    private func hideContentController(content: UIViewController?) {
        guard let content = content else {
            return
        }
        content.willMove(toParent: nil)
        content.view.removeFromSuperview()
        content.removeFromParent()
    }

    private func applyThumbnailProcessing(with filter: Filter) {
        guard let editImage = editImage else {
            return
        }

        let imageFilter = ImageFilter(name: filter.rawValue)

        if let filteredImage = imageFilter?.applyFilter(image: editImage, filter: filter) {
            self.configuration.thumbnailImagesWithFilters[filter.identifier] = filteredImage
            DispatchQueue.main.async {
                self.thumbnailPhotosCollectionView.reloadData()
            }
        }
    }

    private func applyProcessing(with filter: Filter) {
        guard let editImage = editImage else {
            return
        }

        if let filteredImage = imageFilter?.applyFilter(image: editImage, filter: filter) {
            DispatchQueue.main.async {[unowned self] in
                hideContentController(content: loadingViewController)
                self.imageView.image = filteredImage
            }
        }
    }

    private func makeAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Make post", message: "Enter a photo description", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Description..."
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert, self] (action) -> Void in
            let textField = (alert?.textFields?[0])! as UITextField

            guard let image = self.imageView.image else {
                return
            }

            self.displayContentController(content: self.loadingViewController)

            newtworkProcessing.POSTimage(image: image, description: textField.text, withSerializer: nil) {
                DispatchQueue.main.async { [weak self] in
                    self?.hideContentController(content: self?.loadingViewController)
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            DispatchQueue.main.async { [weak self] in
                self?.hideContentController(content: self?.loadingViewController)
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }))

        return alert
    }

}

// MARK: UICollectionViewDelegate Protocol

extension PhotoEditorViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let queue = DispatchQueue.global(qos: .utility)

        displayContentController(content: loadingViewController)

        currentFilter = Filter.allCases[indexPath.row]
        imageFilter = ImageFilter(name: currentFilter.rawValue)

        queue.async {[unowned self] in
            guard currentFilter != .NoFilters else {
                DispatchQueue.main.async {
                    hideContentController(content: loadingViewController)
                    self.imageView.image = editImage
                }

                return
            }

            applyProcessing(with: currentFilter)
        }
    }

}

// MARK: UICollectionViewDataSource Protocol

extension PhotoEditorViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Filter.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let thumbnailCell = thumbnailPhotosCollectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailPhotoCollectionViewCell.identifier, for: indexPath) as! ThumbnailPhotoCollectionViewCell
        let identifier = Filter.allCases[indexPath.row].identifier

        thumbnailCell.thumbnailPhotoImageView.image = configuration.thumbnailImagesWithFilters[identifier]
        thumbnailCell.filterNameLabel.text = identifier

        return thumbnailCell
    }

}

// MARK: - Helper

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
