//
//  Photo.swift
//  UnoloAssignment
//
//  Created by Pratibha Rai on 16/06/26.
//


import Foundation

struct Photo: Decodable {
    let id: Int
    let albumId: Int
    let title: String
    let url: String
    let thumbnailUrl: String
}