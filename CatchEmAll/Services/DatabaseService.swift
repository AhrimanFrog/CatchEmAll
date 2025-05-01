import UIKit
import CoreData
import Combine

class DatabaseService: DBProvider {
    private let queue = DispatchQueue(label: "storage.queue", attributes: .concurrent)
    private let fileManager: FileManager
    private let dbContext: NSManagedObjectContext?
    private let imagesDir: URL?

    init(dbContext: NSManagedObjectContext? = nil, fileManager: FileManager = .default) {
        self.dbContext = dbContext
        self.fileManager = fileManager

        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        imagesDir = documentsURL?.appending(path: "images")
    }

    func preserveImage(_ image: UIImage, withID imageId: UInt) {
        queue.async { [imagesDir] in
            guard let imageData = image.pngData(), let imagesDir else { return }
            try? imageData.write(to: imagesDir.appending(path: "\(imageId).png"))
        }
    }

    func retrieveImage(byID imageID: UInt) -> UIImage? {
        guard let imagesDir else { return nil }
        let filePath = imagesDir.appending(path: "\(imageID).png").path()
        if fileManager.fileExists(atPath: filePath) {
            return UIImage(contentsOfFile: filePath)
        }
        return nil
    }
}
