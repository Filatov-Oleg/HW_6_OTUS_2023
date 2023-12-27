//
//  ContentView.swift
//  HW_6_OTUS_2023
//
//  Created by Филатов Олег Олегович on 17.12.2023.
//

import SwiftUI

struct ContentView: View {

    @StateObject var viewModel: SuffixViewModel = .init()
    
    @State var needShowHistorySuffixes: Bool = false
    @State var text: String = ""

    var body: some View {
        VStack {
            TextField("Введите текст", text: $text)
                .padding(10)
                .border(.black)
                .padding(10)
                .submitLabel(SubmitLabel.done)
                .onSubmit {
                    Task {
                        await viewModel.countSuffixesFrom(text:text)
                    }
                }
            Text(viewModel.suffixSort == .ASC ? "По возрастанию" :  "По убыванию")
            
            List { 
                ForEach(viewModel.sortedSuffixes) { model in
                    HStack{
                        Text(model.suffix)
                        Spacer()
                        Text(String(model.count))
                        Spacer()
                        Text(String(describing: model.time) + " s")
                    }
                    .listRowBackground(Color.green.opacity(opacityForegroundText(for: model.id.uuidString)))
                }
            }
            .listStyle(.plain)

            HStack {
                Button {
                    viewModel.changeSort()
                } label: {
                    Text(viewModel.suffixSort == .ASC ? "По убыванию" : "По возрастанию")
                }.buttonStyle(.bordered)
                Button {
                    needShowHistorySuffixes.toggle()
                } label: {
                    Text("История суффиксов")
                }.buttonStyle(.bordered)
            }
        }
        .sheet(isPresented: $needShowHistorySuffixes, content: {
            List(viewModel.historyText, id: \.self) { text in
                HStack{
                    Text(text)
                }
            }
            .listStyle(.plain)
        })
    }
    
    func opacityForegroundText(for suffixId: String) -> Double {
        guard let modelIndex = viewModel.sortedSuffixes.firstIndex(where: { model in
            model.id.uuidString == suffixId
        }) else {
            return 1.0
        }
        let result = Double(modelIndex) / Double(viewModel.sortedSuffixes.count)
        return viewModel.suffixSort == .ASC ? 1 - result : result
    }
}
