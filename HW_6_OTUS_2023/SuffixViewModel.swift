//
//  SuffixViewModel.swift
//  HW_6_OTUS_2023
//
//  Created by Филатов Олег Олегович on 19.12.2023.
//

import Foundation
import SwiftUI
import CoreData

class SuffixViewModel: ObservableObject {
    
    @Published var sortedSuffixes: [SuffixModel] = .init()
    @Published var historyText: [SuffixCD] = .init()

    let mocSavedSuffix: NSManagedObjectContext

    init(mocSavedSuffix: NSManagedObjectContext) {
        self.mocSavedSuffix = mocSavedSuffix
    }
    
    var suffixSort: SuffixSort = .ASC
    
    private var suffixes: [SuffixModel] = []
    private let jobScheduler = JobScheduler(concurrency: 3)
    
    @MainActor
    func countSuffixesFrom(text: String) async {
        let words = text.split(separator: " ").map { String($0) }
        suffixes = try! await withThrowingTaskGroup(of: [String: (Int, UInt64)].self, returning: [SuffixModel].self) { taskGroup in
            for word in words {
                let startTimeForWord: UInt64 = DispatchTime.now().uptimeNanoseconds
                taskGroup.addTask {
                    let result = try! await self.jobScheduler.addJob(operation:{
                         self.findSuffixes(in: word, startTime: startTimeForWord)
                    })
                    return result
                }

            }
            var interimResult = [String: (count: Int, time: UInt64)]()
            for try await task in taskGroup {
                interimResult.merge(task) {($0.count + $1.count, $0.time + $1.time)}
            }
    
            let finalResult =  interimResult.map { SuffixModel(suffix: $0.key, count: $0.value.count, time: Decimal($0.value.time) / pow(10, 9)) }.sorted(by: <)
            return finalResult
        }
        sortedSuffixes = suffixes
        addToHistory(text)
    }
    
    func findSuffixes(in text: String, startTime: UInt64) -> [String: (Int, UInt64)] {
        let words = text.split(separator: " ")
        let suffixArray = words.flatMap{ SuffixSequence(word: String($0)).map { $0 } }
        var resultSuffixes: [String: (count: Int, time: UInt64)] = [:]
        
        for i in suffixArray {
            resultSuffixes[i as! String, default: (0, UInt64())].count += 1
            resultSuffixes[i as! String, default: (0, UInt64())].time += (DispatchTime.now().uptimeNanoseconds - startTime)
        }
        return resultSuffixes
    }

    func changeSort() {
        switch suffixSort {
        case .ASC:
            suffixSort = .DESC
            suffixes.sort(by: >)
        case .DESC:
            suffixSort = .ASC
            suffixes.sort(by: <)
        }
        sortedSuffixes = suffixes
    }
}

// MARK: Core Data

extension SuffixViewModel {
    func fetchData() {
        let request = SuffixCD.fetchRequest()
        if let savedSuffixes = try? mocSavedSuffix.fetch(request) {
            self.historyText = savedSuffixes
        }
    }
    
    func addToHistory(_ text: String) {
        let newText = SuffixCD(context: mocSavedSuffix)
        newText.id = UUID()
        newText.text = text
        if mocSavedSuffix.hasChanges {
            try? mocSavedSuffix.save()
        }
        historyText.append(newText)
    }
    
    func deleteSuffix(at indexes: IndexSet) {
        for index in indexes {
            let text = historyText[index]
            mocSavedSuffix.delete(text)
        }
        historyText.remove(atOffsets: indexes)
        if mocSavedSuffix.hasChanges {
            try? mocSavedSuffix.save()
        }
    }
}
