import Foundation
import CoreData


extension DBMove {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBMove> {
        return NSFetchRequest<DBMove>(entityName: "Move")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?

}

extension DBMove : Identifiable {}
