//
//  PhotoEntity+CoreDataProperties.swift
//  UnoloAssignment
//
//  Created by Pratibha Rai on 16/06/26.
//
//

public import Foundation
public import CoreData


public typealias PhotoEntityCoreDataPropertiesSet = NSSet

extension PhotoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoEntity> {
        return NSFetchRequest<PhotoEntity>(entityName: "PhotoEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var albumId: Int64
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var thumbnailUrl: String?

}

extension PhotoEntity : Identifiable {

}
