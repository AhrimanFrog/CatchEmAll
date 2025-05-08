import UIKit
import CoreData
import Combine

class DatabaseService: DBProvider {
    private let dbQueue = DispatchQueue(label: "storage.queue", attributes: .concurrent)
    private let imageQueue = DispatchQueue(label: "image.queue", attributes: .concurrent)
    private let fileManager: FileManager
    private let dbContext: NSManagedObjectContext
    private let imagesDir: URL

    init(dbContext: NSManagedObjectContext, fileManager: FileManager = .default) {
        self.dbContext = dbContext
        self.fileManager = fileManager

        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        imagesDir = documentsURL.appending(path: "images")
        try? fileManager.createDirectory(at: imagesDir, withIntermediateDirectories: true)
    }

    func preserveImage(_ imageData: Data, withID imageId: UInt) {
        imageQueue.async { [imagesDir] in
            try? imageData.write(to: imagesDir.appending(path: "\(imageId).png"))
        }
    }

    func retrieveImage(byID imageID: UInt) -> Data? {
        imageQueue.sync {
            let filePath = imagesDir.appending(path: "\(imageID).png").path()
            return fileManager.contents(atPath: filePath)
        }
    }

    func preservePokemon(_ pokemon: APIPokemon) {
        dbQueue.async { [weak self] in
            guard let self else { return }

            let dbPokemon = DBPokemon(context: dbContext)
            dbPokemon.id = Int64(pokemon.id)
            dbPokemon.name = pokemon.name
            dbPokemon.height = Int16(pokemon.height)
            dbPokemon.weight = Int16(pokemon.weight)
            dbPokemon.attack = Int16(pokemon.attack)
            dbPokemon.damage = Int16(pokemon.damage)

            for apiMove in pokemon.moves {
                let dbMove = DBMove(context: dbContext)
                dbMove.id = Int64(apiMove.move.id)
                dbMove.name = apiMove.move.name
                dbMove.addToPokemon(dbPokemon)
            }

            for apiStat in pokemon.stats {
                let dbStat = DBStat(context: dbContext)
                dbStat.id = Int64(apiStat.stat.id)
                dbStat.name = apiStat.stat.name
                dbStat.value = Int64(apiStat.baseStat)
                dbStat.addToPokemon(dbPokemon)
            }

            saveContext()
        }
    }

    func retrievePokemon(offset: UInt, limit: UInt) -> [DBPokemon]? {
        dbQueue.sync {
            let request = DBPokemon.fetchRequest()
            request.fetchLimit = Int(limit)
            request.fetchOffset = Int(offset)
            return try? dbContext.fetch(request)
        }
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
