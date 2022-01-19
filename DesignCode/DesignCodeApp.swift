//
//  DesignCodeApp.swift
//  DesignCode
//
//  Created by Nick Rice on 29/12/2021.
//

import SwiftUI
import Firebase

@main
struct DesignCodeApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
