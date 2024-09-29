//
//  Post.swift
//  Posts_swiftui_prototype
//
//  Created by mahesh lad on 29/09/2024.
//

import Foundation

struct Post: Codable, Identifiable, Prototype, Equatable {
    let id: Int
    let title: String
    let body: String
    
    func clone() -> Post {
        return Post(id: self.id, title: self.title, body: self.body)
    }
    
    // Equatable conformance
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.body == rhs.body
    }
}
// MARK: - Prototype Protocol

protocol Prototype {
    func clone() -> Self
}

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}
