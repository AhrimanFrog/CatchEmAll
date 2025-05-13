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

    func preservePokemon(_ pokemon: Pokemon) {
        dbBgContext.perform { [weak self] in
            guard let self else { return }

            let dbPokemon = DBPokemon(context: dbBgContext)
            dbPokemon.id = Int64(pokemon.id)
            dbPokemon.name = pokemon.name
            dbPokemon.height = Int16(pokemon.height)
            dbPokemon.weight = Int16(pokemon.weight)
            dbPokemon.abilities = pokemon.abilities.encode()
            dbPokemon.moves = pokemon.moves.encode()

            for stat in pokemon.stats {
                let dbStat = DBStat(context: dbBgContext)
                dbStat.name = stat.name
                dbStat.value = Int64(stat.value)
                dbStat.addToPokemon(dbPokemon)
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
                guard let pokemon = retrieveSinglePokemon(byID: pokemonID) else {
                    return promise(.failure(.notFound))
                }
                return promise(.success(pokemon))
            }
        }
        .eraseToAnyPublisher()
    }

    func preserveEvolution(chain: [UInt], forPokemonID pokemonID: UInt) {
        dbBgContext.perform { [weak self] in
            guard let dbPokemon = self?.retrieveSinglePokemon(byID: pokemonID) else { return }
            dbPokemon.evolutionChain = chain.encode()
            self?.saveContext()
        }
    }

    func retrieveEvolutionChain(byPokemonID pokemonID: UInt) -> AnyPublisher<[UInt], DBError> {
        Future { [weak self] promise in
            self?.dbFgContext.perform { [weak self] in
                guard let dbPokemon = self?.retrieveSinglePokemon(byID: pokemonID) else {
                    return promise(.failure(.notFound))
                }
                guard let chain = dbPokemon.evolutionChain?.decodeTo(type: [UInt].self) else {
                    return promise(.failure(.notFound))
                }
                return promise(.success(chain))
            }
        }
        .eraseToAnyPublisher()
    }

    private func retrieveSinglePokemon(byID pokemonID: UInt) -> DBPokemon? {
        let request = DBPokemon.fetchRequest()
        request.fetchLimit = 1
        request.predicate = .init(format: "id == %@", pokemonID)
        return try? dbFgContext.fetch(request).first
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
