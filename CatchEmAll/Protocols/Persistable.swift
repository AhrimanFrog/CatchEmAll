import CoreData

protocol Persistable {
    associatedtype ManagedObject = NSManagedObject
    func persist(inObject: ManagedObject)
}
