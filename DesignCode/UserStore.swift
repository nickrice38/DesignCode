//
//  UserStore.swift
//  DesignCode
//
//  Created by Nick Rice on 20/01/2022.
//

import SwiftUI
import Combine

class UserStore: ObservableObject{
    @Published var isLogged: Bool = UserDefaults.standard.bool(forKey: "isLogged") {
        didSet {
            UserDefaults.standard.set(self.isLogged, forKey: "isLogged") // when the application loads, we're going to pull any data that has already been stored in UserDefaults for isLogged. self being our UserStore class
        }
    }
    @Published var showLogin = false
}
