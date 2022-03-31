import UIKit

class HubViewController: UIViewController {

    // MARK: - Internal Types

    struct ImagePost: Equatable {
        let id: Int
        let url: String
        let description: String

        static var empty: Self {
            return .init(id: 0, url: "", description: "")
        }
    }

    private typealias BlurStyle = UIBlurEffect.Style

    // MARK: - Private Properties

    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var hubTableView: UITableView!
    private let loadingViewController = LoadingViewController()

    private var blurEffectView: UIVisualEffectView?
    private var selectedImageIndex = 0

    private let newtworkProcessing = NetworkProcessing(apiURL: "https://filterhub.pythonanywhere.com/images/")

    private var dataSource: [ImagePost] = [] {
        didSet {
            if oldValue != dataSource {
                DispatchQueue.main.async { [weak self] in
                    self?.hubTableView.reloadData()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        applyBlur()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        selectedImageIndex = Int.random(in: 1...11)
        backgroundImageView.image = UIImage(named: String(describing: selectedImageIndex))

        loadImages()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        blurEffectView?.frame = view.bounds
    }

    private func applyBlur() {
        let style: BlurStyle = UITraitCollection.current.userInterfaceStyle == .light ? .light : .dark
        let blurEffect = UIBlurEffect(style: style)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView!)
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

    private func loadImages() {
        dataSource = []
        displayContentController(content: loadingViewController)
        newtworkProcessing.GET(data: nil, withSerializer: postSerializer) {
            DispatchQueue.main.async { [weak self] in
                self?.hideContentController(content: self?.loadingViewController)
            }
        }
    }

    private func postSerializer(_ data: Any) -> Bool {
        guard let data = data as? Data else {
            return false
        }

        let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: [])
        guard let jsonArray = jsonResponse as? [[String : Any]] else {
            return false
        }

        for json in jsonArray {
            if let id = json["id"] as? Int,
               let url = json["image"] as? String,
               let description = json["description"] as? String {
                dataSource.append(.init(id: id, url: url, description: description))
            }
        }

        return true
    }
}

extension HubViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HubPostTableViewCell.identifier, for: indexPath) as? HubPostTableViewCell else {
            return UITableViewCell()
        }

        cell.backgroundColor = .clear
        cell.backgroundView = .init()

        cell.post = .init(url: dataSource[indexPath.row].url, description: dataSource[indexPath.row].description)

        return cell
    }

}
