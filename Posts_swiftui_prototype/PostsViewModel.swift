//
//  PostsViewModel.swift
//  Posts_swiftui_prototype
//
//  Created by mahesh lad on 29/09/2024.
//

import Foundation

class PostsViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var errorMessage: String?
    
    var networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func fetchPosts() async {
        do {
            let fetchedPosts: [Post] = try await networkService.fetchData(from: "https://jsonplaceholder.typicode.com/posts")
            DispatchQueue.main.async {
                self.posts = fetchedPosts
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func duplicatePost(at index: Int) {
        guard index < posts.count else { return }
        let newPost = posts[index].clone()
        posts.append(newPost)
    }
}
