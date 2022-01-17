//
//  DataStore.swift
//  DesignCode
//
//  Created by Nick Rice on 16/01/2022.
//

import Foundation
import SwiftUI
import Combine

class DataStore: ObservableObject {
    @Published var posts: [Post] = [] // has a default of an empty array
    
    init() {
        getPosts()
    }
    
    func getPosts() {
        Api().getPosts { (posts) in
            self.posts = posts
        }
    }
}
