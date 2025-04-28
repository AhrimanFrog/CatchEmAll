import Foundation
import CoreData


extension DBPokemon {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBPokemon> {
        return NSFetchRequest<DBPokemon>(entityName: "Pokemon")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var height: Int16
    @NSManaged public var weight: Int16
    @NSManaged public var image: Data?
    @NSManaged public var attack: Int16
    @NSManaged public var damage: Int16
    @NSManaged public var stats: NSSet?
    @NSManaged public var moves: NSSet?
}

// MARK: Generated accessors for stats
extension DBPokemon {
    @objc(addStatsObject:)
    @NSManaged public func addToStats(_ value: DBStat)

    @objc(removeStatsObject:)
    @NSManaged public func removeFromStats(_ value: DBStat)

    @objc(addStats:)
    @NSManaged public func addToStats(_ values: NSSet)

    @objc(removeStats:)
    @NSManaged public func removeFromStats(_ values: NSSet)

}

// MARK: Generated accessors for moves
extension DBPokemon {
    @objc(addMovesObject:)
    @NSManaged public func addToMoves(_ value: DBMove)

    @objc(removeMovesObject:)
    @NSManaged public func removeFromMoves(_ value: DBMove)

    @objc(addMoves:)
    @NSManaged public func addToMoves(_ values: NSSet)

    @objc(removeMoves:)
    @NSManaged public func removeFromMoves(_ values: NSSet)

}

extension DBPokemon : Identifiable {}
