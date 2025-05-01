import UIKit

protocol DBProvider {
    func preserveImage(_ image: Data, withID imageId: UInt)
    func retrieveImage(byID imageID: UInt) -> Data?
}
