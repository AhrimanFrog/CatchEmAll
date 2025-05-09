import UIKit
import CoreData
import Combine

class DatabaseService: DBProvider {
    private let imageQueue = DispatchQueue(label: "image.queue", attributes: .concurrent)
    private let fileManager: FileManager
    private let dbBgContext: NSManagedObjectContext
    private let dbFgContext: NSManagedObjectContext
    private let imagesDir: URL

    init(container: NSPersistentContainer, fileManager: FileManager = .default) {
        self.dbBgContext = container.newBackgroundContext()
        self.dbFgContext = container.viewContext
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

    func retrieveImage(byID imageID: UInt) -> AnyPublisher<Data, DBError> {
        return Future { [weak self] promise in
            self?.imageQueue.async { [weak self] in
                guard let self else { return promise(.failure(.expired)) }
                let filePath = imagesDir.appending(path: "\(imageID).png").path()
                guard let data = fileManager.contents(atPath: filePath) else { return promise(.failure(.notFound)) }
                promise(.success(data))
            }
        }
        .eraseToAnyPublisher()
    }

    func preservePokemon(_ pokemon: APIPokemon) {
        dbBgContext.perform { [weak self] in
            guard let self else { return }

            let dbPokemon = DBPokemon(context: dbBgContext)
            dbPokemon.id = Int64(pokemon.id)
            dbPokemon.name = pokemon.name
            dbPokemon.height = Int16(pokemon.height)
            dbPokemon.weight = Int16(pokemon.weight)
            dbPokemon.attack = Int16(pokemon.attack)
            dbPokemon.damage = Int16(pokemon.damage)

            for apiMove in pokemon.moves {
                let dbMove = DBMove(context: dbBgContext)
                dbMove.id = Int64(apiMove.move.id)
                dbMove.name = apiMove.move.name
                dbMove.addToPokemon(dbPokemon)
            }

            for apiStat in pokemon.stats {
                let dbStat = DBStat(context: dbBgContext)
                dbStat.id = Int64(apiStat.stat.id)
                dbStat.name = apiStat.stat.name
                dbStat.value = Int64(apiStat.baseStat)
                dbStat.addToPokemon(dbPokemon)
            }

            for apiAbility in pokemon.abilities {
                let dbAbility = DBAbility(context: dbBgContext)
                dbAbility.id = Int64(apiAbility.ability.id)
                dbAbility.name = apiAbility.ability.name
                dbAbility.addToPokemon(dbPokemon)
            }

            saveContext()
        }
    }

    func retrievePokemon(offset: UInt, limit: UInt) -> AnyPublisher<[DBPokemon], DBError> {
        Future { [weak self] promise in
            self?.dbFgContext.perform { [weak self] in
                guard let self else { return promise(.failure(.expired)) }
                let request = DBPokemon.fetchRequest()
                request.fetchLimit = Int(limit)
                request.fetchOffset = Int(offset)
                guard let pokemon = try? dbFgContext.fetch(request), !pokemon.isEmpty else {
                    return promise(.failure(.notFound))
                }
                return promise(.success(pokemon))
            }
        }
        .eraseToAnyPublisher()
    }

    func retrievePokemon(byID pokemonID: UInt) -> AnyPublisher<DBPokemon, DBError> {
        Future { [weak self] promise in
            self?.dbFgContext.perform { [weak self] in
                guard let self else { return promise(.failure(.expired)) }
                let request = DBPokemon.fetchRequest()
                request.fetchLimit = 1
                request.predicate = .init(format: "id == %@", pokemonID)
                guard let pokemon = try? dbFgContext.fetch(request).first else {
                    return promise(.failure(.notFound))
                }
                return promise(.success(pokemon))
            }
        }
        .eraseToAnyPublisher()
    }

    private func saveContext() {
        guard dbBgContext.hasChanges else { return }
        do {
            try dbBgContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
