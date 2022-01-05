//
//  UpdateStore.swift
//  DesignCode
//
//  Created by Nick Rice on 30/12/2021.
//

import SwiftUI
import Combine

class UpdateStore: ObservableObject {
    @Published var updates: [Update] = updateData
}
