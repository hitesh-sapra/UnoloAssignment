//
//  PageTracker.swift
//  UnoloAssignment
//
//  Created by Hitesh Sapraon 16/06/26.
//


import Foundation

final class PageTracker {
    
    static let shared = PageTracker()
    
    private let key = "fetched_pages"
    private var fetchedPages: Set<Int>
    
    private init() {
        let saved = UserDefaults.standard.array(forKey: key) as? [Int] ?? []
        fetchedPages = Set(saved)
    }
    
    func markFetched(page: Int) {
        fetchedPages.insert(page)
        UserDefaults.standard.set(Array(fetchedPages), forKey: key)
    }
    
    func isFetched(page: Int) -> Bool {
        return fetchedPages.contains(page)
    }
    
    func reset() {
        fetchedPages.removeAll()
        UserDefaults.standard.removeObject(forKey: key)
    }
}
