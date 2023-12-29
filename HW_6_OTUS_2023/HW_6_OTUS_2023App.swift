//
//  HW_6_OTUS_2023App.swift
//  HW_6_OTUS_2023
//
//  Created by Филатов Олег Олегович on 17.12.2023.
//

import SwiftUI

@main
struct HW_6_OTUS_2023App: App {
    
    @StateObject private var coreDataController = CoreDataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SuffixViewModel(mocSavedSuffix: coreDataController.container.viewContext))
        }
    }
}
