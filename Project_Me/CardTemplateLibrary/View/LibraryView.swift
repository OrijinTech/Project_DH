//
//  LibraryView.swift
//  Project_Me
//
//  Created by mac on 2024/5/4.
//

import SwiftUI

struct LibraryView: View {
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: DetailView()) {
                    Text("Go to Detail View")
                }
            }
            .navigationBarTitle("Home")
        }
    }
}

struct DetailView: View {
    var body: some View {
        Text("This is the detail view")
            .navigationBarTitle("Detail", displayMode: .inline)
    }
}

#Preview {
    LibraryView()
}
