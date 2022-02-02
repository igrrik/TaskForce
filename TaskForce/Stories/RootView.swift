//
//  RootView.swift
//  TaskForce
//
//  Created by Igor Kokoev on 01.02.2022.
//

import SwiftUI

struct RootView: View {
    @StateObject var viewModel: RootViewModel

    var body: some View {
        NavigationView {
            List(viewModel.characters) { character in
                Text(character.name)
            }
            .navigationTitle("Characters")
        }
        .task { viewModel.loadMoreData() }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(viewModel: <#RootViewModel#>)
    }
}
