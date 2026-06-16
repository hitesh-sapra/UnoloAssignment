//
//  PhotoListState.swift
//  UnoloAssignment
//
//  Created by Hitesh Sapraon 16/06/26.
//


import Foundation

enum PhotoListState {
    case idle
    case loading
    case loaded
    case error(String)
    case empty
}

final class PhotoListViewModel {
    
    private let repository = PhotoRepository.shared
    private let network = NetworkService.shared
    private let pageTracker = PageTracker.shared
    
    private let pageSize = 20
    private var currentPage = 1
    private var isFetching = false
    private var hasMoreData = true
    
    private(set) var photos: [PhotoEntity] = []
    
    var onStateChange: ((PhotoListState) -> Void)?
    var onPhotosUpdated: (() -> Void)?
    
    func loadInitialData() {
        onStateChange?(.loading)
        loadNextPage()
    }
    
    func loadNextPage() {
        guard !isFetching, hasMoreData else { return }
        isFetching = true
        
        if pageTracker.isFetched(page: currentPage) {
            loadFromCoreData()
        } else {
            fetchFromNetwork()
        }
    }
    
    func refresh() {
        currentPage = 1
        hasMoreData = true
        photos.removeAll()
        onPhotosUpdated?()
        loadInitialData()
    }
    
    func deletePhoto(at index: Int, completion: @escaping (Bool) -> Void) {
        let entity = photos[index]
        repository.delete(entity) { [weak self] error in
            guard let self else { return }
            DispatchQueue.main.async {
                if error == nil {
                    self.photos.remove(at: index)
                    if self.photos.isEmpty {
                        self.onStateChange?(.empty)
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func photo(at index: Int) -> PhotoEntity {
        return photos[index]
    }
    
    var photoCount: Int {
        return photos.count
    }
    
    private func loadFromCoreData() {
        let offset = photos.count
        let batch = repository.fetchPhotos(offset: offset, limit: pageSize)
        
        guard !batch.isEmpty else {
            hasMoreData = false
            isFetching = false
            if photos.isEmpty {
                onStateChange?(.empty)
            }
            return
        }
        
        photos.append(contentsOf: batch)
        currentPage += 1
        isFetching = false
        onStateChange?(.loaded)
        onPhotosUpdated?()
    }
    
    private func fetchFromNetwork() {
        network.fetchPhotos(page: currentPage, limit: pageSize) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let fetched):
                guard !fetched.isEmpty else {
                    DispatchQueue.main.async {
                        self.hasMoreData = false
                        self.isFetching = false
                        if self.photos.isEmpty {
                            self.onStateChange?(.empty)
                        }
                    }
                    return
                }
                
                self.repository.savePhotos(fetched) { error in
                    DispatchQueue.main.async {
                        if let _ = error {
                            self.isFetching = false
                            self.onStateChange?(.error("Failed to save photos. Please try again."))
                        } else {
                            self.pageTracker.markFetched(page: self.currentPage)
                            self.loadFromCoreData()
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isFetching = false
                    switch error {
                    case .requestFailed:
                        self.onStateChange?(.error("No internet connection. Please check your network."))
                    default:
                        self.onStateChange?(.error("Something went wrong. Please try again."))
                    }
                }
            }
        }
    }
    
    func deletePhotoFromDetail(at index: Int, completion: @escaping (Bool) -> Void) {
        guard index < photos.count else {
            completion(false)
            return
        }
        photos.remove(at: index)
        if photos.isEmpty {
            onStateChange?(.empty)
        }
        completion(true)
    }
}
