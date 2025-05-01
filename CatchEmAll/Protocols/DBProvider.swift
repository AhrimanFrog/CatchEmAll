import UIKit

protocol DBProvider {
    func preserveImage(_ image: UIImage, withID imageId: UInt)
    func retrieveImage(byID imageID: UInt) -> UIImage?
}
