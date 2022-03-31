import UIKit

enum Filter: String, CaseIterable {

    case NoFilters
    case CIGaussianBlur
    case CIPhotoEffectNoir
    case CIColorInvert
    case CISepiaTone
    case CIPixellate
    case CIPhotoEffectChrome
    case CIPhotoEffectFade
    case CIPhotoEffectInstant
    case CIPhotoEffectMono
    case CIPhotoEffectProcess
    case CIPhotoEffectTonal
    case CIPhotoEffectTransfer
    case CITwirlDistortion
    case CIVignette
    case CIUnsharpMask
    case CIBumpDistortion

    var identifier: String {
        var id = rawValue.replacingOccurrences(of: "CI", with: "")
        id = id.replacingOccurrences(of: "Photo", with: "")
        id = id.replacingOccurrences(of: "Effect", with: "")
        return id
    }

}


class ImageFilter {

    // MARK: - Private Properties

    private let context: CIContext
    private let ciFilter: CIFilter

    init?(name: String) {
        self.context = CIContext()
        guard let filter = CIFilter(name: name) else {
            return nil
        }
        self.ciFilter = filter
    }

    // MARK: - Public Properties

    public func applyFilter(image: UIImage, filter: Filter) -> UIImage? {
        guard let ciImage = CIImage(image: image) else {
            return nil
        }

        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        let inputKeys = ciFilter.inputKeys

        if (inputKeys.contains(kCIInputCenterKey)) { ciFilter.setValue(CIVector(x: image.size.width / 2, y: image.size.height / 2), forKey: kCIInputCenterKey) }

        guard let outputImage = ciFilter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

}
