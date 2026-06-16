//
//  PhotoRepository.swift
//  UnoloAssignment
//
//  Created by Hitesh Sapraon 16/06/26.
//


import CoreData

final class PhotoRepository {
    
    static let shared = PhotoRepository()
    
    private let stack = CoreDataStack.shared
    
    private init() {}
    
    func savePhotos(_ photos: [Photo], completion: @escaping (Error?) -> Void) {
        let context = stack.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        context.perform {
            let existingIds = self.fetchExistingIds(in: context)
            
            for photo in photos {
                guard !existingIds.contains(Int64(photo.id)) else { continue }
                
                let entity = PhotoEntity(context: context)
                entity.id = Int64(photo.id)
                entity.albumId = Int64(photo.albumId)
                entity.title = photo.title
                entity.url = "https://picsum.photos/seed/\(photo.id)/600/600"
                entity.thumbnailUrl = "https://picsum.photos/seed/\(photo.id)/150/150"
            }
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                context.rollback()
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }
    
    func fetchPhotos(offset: Int, limit: Int) -> [PhotoEntity] {
        let request = PhotoEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        request.fetchOffset = offset
        request.fetchLimit = limit
        
        do {
            return try stack.viewContext.fetch(request) as? [PhotoEntity] ?? []
        } catch {
            return []
        }
    }
    
    func totalCount() -> Int {
        let request = PhotoEntity.fetchRequest()
        return (try? stack.viewContext.count(for: request)) ?? 0
    }
    
    func updateTitle(for entity: PhotoEntity, newTitle: String, completion: @escaping (Error?) -> Void) {
        let context = stack.viewContext
        entity.title = newTitle
        do {
            try context.save()
            completion(nil)
        } catch {
            context.rollback()
            completion(error)
        }
    }
    
    func delete(_ entity: PhotoEntity, completion: @escaping (Error?) -> Void) {
        let context = stack.viewContext
        context.delete(entity)
        do {
            try context.save()
            completion(nil)
        } catch {
            context.rollback()
            completion(error)
        }
    }
    
    private func fetchExistingIds(in context: NSManagedObjectContext) -> Set<Int64> {
        let request = PhotoEntity.fetchRequest()
        request.propertiesToFetch = ["id"]
        request.resultType = .dictionaryResultType
        
        guard let results = try? context.fetch(request) as? [[String: Any]] else { return [] }
        let ids = results.compactMap { $0["id"] as? Int64 }
        return Set(ids)
    }
}
