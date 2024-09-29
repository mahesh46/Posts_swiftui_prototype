//
//  NetworkService.swift
//  Posts_swiftui_prototype
//
//  Created by mahesh lad on 29/09/2024.
//

import Foundation


class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService(urlSession: URLSession.shared)
    private let urlSession: URLSessionProtocol
    
    init(urlSession: URLSessionProtocol) {
        self.urlSession = urlSession
    }
    
    func fetchData<T: Codable>(from urlString: String) async throws -> [T] {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([T].self, from: data)
    }
}


// MARK: - Protocols

protocol NetworkServiceProtocol {
    func fetchData<T: Codable>(from urlString: String) async throws -> [T]
}

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

// MARK: - Mock Classes

class MockNetworkService: NetworkServiceProtocol {
    var mockResult: Result<[Post], Error>?
    
    func fetchData<T: Codable>(from urlString: String) async throws -> [T] {
        guard let mockResult = mockResult else {
            fatalError("Mock result not set")
        }
        
        switch mockResult {
        case .success(let posts):
            return posts as! [T]
        case .failure(let error):
            throw error
        }
    }
}

class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let mockError = mockError {
            throw mockError
        }
        guard let mockData = mockData, let mockResponse = mockResponse else {
            fatalError("Mock data or response not set")
        }
        return (mockData, mockResponse)
    }
}
