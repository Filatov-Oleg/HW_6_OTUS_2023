//
//  HistorySuffixesListView.swift
//  HW_6_OTUS_2023
//
//  Created by Филатов Олег Олегович on 29.12.2023.
//

import SwiftUI

struct HistorySuffixesListView: View {

    @EnvironmentObject var viewModel: SuffixViewModel

    var body: some View {
        List {
            ForEach(viewModel.historyText) { model in
                HStack{
                    Text(model.text ?? "")
                }
            }
            .onDelete(perform: { indexSet in
                viewModel.deleteSuffix(at: indexSet)
            })
        }
        .listStyle(.plain)
        .task {
            viewModel.fetchData()
        }
    }
}
