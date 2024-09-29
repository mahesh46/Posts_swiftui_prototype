//
//  ContentView.swift
//  Posts_swiftui_prototype
//
//  Created by mahesh lad on 29/09/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PostsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.posts.indices, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text(viewModel.posts[index].title)
                            .font(.headline)
                        Text(viewModel.posts[index].body)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .swipeActions {
                        Button("Duplicate") {
                            viewModel.duplicatePost(at: index)
                        }
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("Posts")
            .task {
                await viewModel.fetchPosts()
            }
            .alert(item: Binding<AlertItem?>(
                get: { viewModel.errorMessage.map { AlertItem(message: $0) } },
                set: { _ in viewModel.errorMessage = nil }
            )) { alertItem in
                Alert(title: Text("Error"), message: Text(alertItem.message))
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
