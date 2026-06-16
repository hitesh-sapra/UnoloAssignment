//
//  PhotoDetailViewModel.swift
//  UnoloAssignment
//
//  Created by Pratibha Rai on 16/06/26.
//


import Foundation

final class PhotoDetailViewModel {
    
    private let repository = PhotoRepository.shared
    private(set) var photo: PhotoEntity
    
    var onSaveSuccess: (() -> Void)?
    var onSaveError: ((String) -> Void)?
    var onDeleteSuccess: (() -> Void)?
    var onDeleteError: ((String) -> Void)?
    
    init(photo: PhotoEntity) {
        self.photo = photo
    }
    
    var title: String {
        return photo.title ?? ""
    }
    
    var imageURL: URL? {
        return URL(string: photo.url ?? "")
    }
    
    func saveTitle(_ newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            onSaveError?("Title cannot be empty.")
            return
        }
        
        guard trimmed != photo.title else {
            onSaveSuccess?()
            return
        }
        
        repository.updateTitle(for: photo, newTitle: trimmed) { [weak self] error in
            guard let self else { return }
            DispatchQueue.main.async {
                if error == nil {
                    self.onSaveSuccess?()
                } else {
                    self.onSaveError?("Failed to update title. Please try again.")
                }
            }
        }
    }
    
    func deletePhoto() {
        repository.delete(photo) { [weak self] error in
            guard let self else { return }
            DispatchQueue.main.async {
                if error == nil {
                    self.onDeleteSuccess?()
                } else {
                    self.onDeleteError?("Failed to delete photo. Please try again.")
                }
            }
        }
    }
}
