//
//  CoreDataController.swift
//  HW_6_OTUS_2023
//
//  Created by Филатов Олег Олегович on 28.12.2023.
//

import Foundation
import CoreData

class CoreDataController: ObservableObject {
    let container = NSPersistentContainer(name: "SuffixCoreData")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
