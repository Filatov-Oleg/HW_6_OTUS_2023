//
//  ContentView.swift
//  HW_6_OTUS_2023
//
//  Created by Филатов Олег Олегович on 17.12.2023.
//

import SwiftUI
import CoreData

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

struct ContentView: View {

    @EnvironmentObject var viewModel: SuffixViewModel
    
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
                    .listRowBackground(Color(uiColor: colorForegroundText(for: model)))
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
            HistorySuffixesListView()
        })
    }

    func colorForegroundText(for suffixId: SuffixModel) -> UIColor {
        guard let modelIndex = viewModel.sortedSuffixes.firstIndex(where: { model in
            model.id.uuidString == suffixId.id.uuidString
        }) else {
            return .blue
        }
        let itemCount = viewModel.sortedSuffixes.count - 1
        let val = (CGFloat(modelIndex) / CGFloat(itemCount))
        switch viewModel.suffixSort {
        case .ASC:
            return UIColor(red: val, green: 1 - val, blue: 0.0, alpha: 1.0)
        case .DESC:
            return UIColor(red: 1 - val, green: val, blue: 0.0, alpha: 1.0)
        }
    }
}
