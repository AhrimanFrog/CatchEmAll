import Foundation
import CoreData


extension DBStat {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBStat> {
        return NSFetchRequest<DBStat>(entityName: "Stat")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var value: Int16

}

extension DBStat : Identifiable {}
