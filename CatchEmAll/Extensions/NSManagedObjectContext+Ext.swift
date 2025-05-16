import CoreData

extension NSManagedObjectContext {
    func fetchEntity<Entity: NSManagedObject>(_ entity: Entity.Type, byID entityID: UInt) -> Entity? {
        let request = Entity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = .init(format: "id == %u", entityID)
        return try? fetch(request).first as? Entity
    }
}
