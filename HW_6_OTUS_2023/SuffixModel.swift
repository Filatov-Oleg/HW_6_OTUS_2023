//
//  SuffixModel.swift
//  HW_6_OTUS_2023
//
//  Created by Филатов Олег Олегович on 24.12.2023.
//

import Foundation

struct SuffixModel: Identifiable, Comparable {
    var id = UUID()
    let suffix: String
    let count: Int
    let time: Decimal
    
    static func < (lhs: SuffixModel, rhs: SuffixModel) -> Bool {
        return lhs.time < rhs.time
    }
    
    static func > (lhs: SuffixModel, rhs: SuffixModel) -> Bool {
        return lhs.time > rhs.time
    }
}
