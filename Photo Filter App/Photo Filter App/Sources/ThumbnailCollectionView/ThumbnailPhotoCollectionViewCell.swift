import UIKit

class ThumbnailPhotoCollectionViewCell: UICollectionViewCell {

    // MARK: - Static Properties
    static var identifier = "ThumbnailPhotoCollectionViewCell"

    // MARK: - Internal Properties
    @IBOutlet weak var filterNameLabel: UILabel!
    @IBOutlet weak var thumbnailPhotoImageView: UIImageView!
    
}
