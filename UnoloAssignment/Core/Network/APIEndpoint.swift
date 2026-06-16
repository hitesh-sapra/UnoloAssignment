//
//  APIEndpoint.swift
//  UnoloAssignment
//
//  Created by Hitesh Sapraon 16/06/26.
//


import Foundation

enum APIEndpoint {
    case photos(page: Int, limit: Int)

    var url: URL {
        switch self {
        case .photos(let page, let limit):
            var components = URLComponents(string: "https://jsonplaceholder.typicode.com/photos")!
            components.queryItems = [
                URLQueryItem(name: "_page", value: "\(page)"),
                URLQueryItem(name: "_limit", value: "\(limit)")
            ]
            return components.url!
        }
    }
}
