import UIKit
import CoreData
import Combine

class DatabaseService: DBProvider {
    private let queue = DispatchQueue(label: "storage.queue", attributes: .concurrent)
    private let fileManager: FileManager
    private let dbContext: NSManagedObjectContext
    private let imagesDir: URL?

    init(dbContext: NSManagedObjectContext, fileManager: FileManager = .default) {
        self.dbContext = dbContext
        self.fileManager = fileManager

        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        imagesDir = documentsURL?.appending(path: "images")
    }

    func preserveImage(_ imageData: Data, withID imageId: UInt) {
        queue.async { [imagesDir] in
            guard let imagesDir else { return }
            try? imageData.write(to: imagesDir.appending(path: "\(imageId).png"))
        }
    }

    func retrieveImage(byID imageID: UInt) -> Data? {
        guard let imagesDir else { return nil }
        let filePath = imagesDir.appending(path: "\(imageID).png").path()
        return fileManager.contents(atPath: filePath)
    }

    private func saveContext() {
        guard dbContext.hasChanges else { return }
        do {
            try dbContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
