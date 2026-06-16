//
//  NetworkService.swift
//  UnoloAssignment
//
//  Created by Pratibha Rai on 16/06/26.
//

import Foundation

enum NetworkError: Error {
    case invalidResponse
    case decodingFailed
    case requestFailed(Error)
}

final class NetworkService {
    
    static let shared = NetworkService()
    
    private init() {}
    
    func fetchPhotos(page: Int, limit: Int, completion: @escaping (Result<[Photo], NetworkError>) -> Void) {
        let request = URLRequest(url: APIEndpoint.photos(page: page, limit: limit).url,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 30)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let photos = try JSONDecoder().decode([Photo].self, from: data)
                completion(.success(photos))
            } catch {
                completion(.failure(.decodingFailed))
            }
        }.resume()
    }
}
