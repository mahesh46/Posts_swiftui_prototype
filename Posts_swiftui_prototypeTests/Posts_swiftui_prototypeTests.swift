//
//  Posts_swiftui_prototypeTests.swift
//  Posts_swiftui_prototypeTests
//
//  Created by mahesh lad on 29/09/2024.
//

import XCTest
@testable import Posts_swiftui_prototype

class PostsViewModelTests: XCTestCase {
    
    var viewModel: PostsViewModel!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = PostsViewModel(networkService: mockNetworkService! )
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    func testFetchPostsSuccess() async {
        // Given
        let expectedPosts = [Post(id: 1, title: "Test Post", body: "Test Body")]
        mockNetworkService.mockResult = .success(expectedPosts)
        
        // When
        await viewModel.fetchPosts()
        
        // Then
        XCTAssertEqual(viewModel.posts, expectedPosts)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchPostsFailure() async {
        // Given
        let expectedError = NetworkError.invalidResponse
        mockNetworkService.mockResult = .failure(expectedError)
        
        // When
        await viewModel.fetchPosts()
        
        // Then
        XCTAssertTrue(viewModel.posts.isEmpty)
        XCTAssertEqual(viewModel.errorMessage, expectedError.localizedDescription)
    }
    
    func testDuplicatePost() {
        // Given
        let initialPost = Post(id: 1, title: "Original", body: "Body")
        viewModel.posts = [initialPost]
        
        // When
        viewModel.duplicatePost(at: 0)
        
        // Then
        XCTAssertEqual(viewModel.posts.count, 2)
        XCTAssertEqual(viewModel.posts[1].title, "Original")
        XCTAssertNotEqual(viewModel.posts[1].id, viewModel.posts[0].id)
    }
}

class NetworkServiceTests: XCTestCase {
    
    var networkService: NetworkService!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        networkService = NetworkService(urlSession: mockURLSession!)
    }
    
    override func tearDown() {
        networkService = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    func testFetchDataSuccess() async throws {
        // Given
        let expectedPosts = [Post(id: 1, title: "Test Post", body: "Test Body")]
        let jsonData = try JSONEncoder().encode(expectedPosts)
        mockURLSession.mockData = jsonData
        mockURLSession.mockResponse = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        // When
        let result: [Post] = try await networkService.fetchData(from: "https://test.com")
        
        // Then
        XCTAssertEqual(result, expectedPosts)
    }
    
    func testFetchDataInvalidURLFailure() async {
        // Given
        let invalidURL = ""
        
        // When/Then
        do {
            let _: [Post] = try await networkService.fetchData(from: invalidURL)
            XCTFail("Expected to throw an error")
        } catch {
            XCTAssertTrue(error is NetworkError)
            XCTAssertEqual(error as? NetworkError, .invalidURL)
        }
    }
    
    func testFetchDataInvalidResponseFailure() async {
        // Given
        mockURLSession.mockData = Data()
        mockURLSession.mockResponse = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)
        
        // When/Then
        do {
            let _: [Post] = try await networkService.fetchData(from: "https://test.com")
            XCTFail("Expected to throw an error")
        } catch {
            XCTAssertTrue(error is NetworkError)
            XCTAssertEqual(error as? NetworkError, .invalidResponse)
        }
    }
}


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

