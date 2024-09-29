//
//  NetworkError.swift
//  Posts_swiftui_prototype
//
//  Created by mahesh lad on 29/09/2024.
//

import Foundation

// MARK: - Error Handling

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}


