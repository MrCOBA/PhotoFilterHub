import UIKit

final class HubPostTableViewCell: UITableViewCell {

    struct Post: Equatable {
        let url: String
        let description: String

        static var empty: Self {
            return .init(url: "", description: "")
        }
    }

    var post: Post = .empty {
        didSet {
            if oldValue != post {
                updateCell()
            }
        }
    }

    static var identifier: String {
        return "HubPostTableViewCell"
    }

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet private weak var postImageView: CBImageView!

    private let newtworkProcessing = NetworkProcessing(apiURL: "https://filterhub.pythonanywhere.com/images/")

    override func awakeFromNib() {
        super.awakeFromNib()

        updateCell()
    }

    private func updateCell() {
        loadImage()
        descriptionLabel.text = post.description
    }

    private func loadImage() {
        guard post.url != "" else {
            return
        }
        
        newtworkProcessing.GETimage(from: post.url) { (data, response, error) in
            if let error = error {
                print("Error took place \(error)")
                return
            }

            if let data = data {
                DispatchQueue.main.async { [weak self] in
                    self?.postImageView.image = UIImage(data: data) ?? UIImage(named: "no_pictures")!
                }
            }
        }
    }
    
}
