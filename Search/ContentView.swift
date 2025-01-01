//
//  ContentView.swift
//  Search
//
//  Created by Tim Schuchardt on 31.12.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var focussed = false
    @AppStorage("privateMode") var privateMode = false

    var body: some View {
        ZStack {
            VStack {
                TabView (selection: $selectedTab) {
                    if !privateMode {
                        SearchView(focussed: $focussed)
                            .tag(0)
                    }
                    else {
                        PrivateSearchView(focussed: $focussed)
                            .tag(0)
                    }
                    SettingsView()
                        .tag(1)
                        .gesture(DragGesture())

                }
                
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .padding()
                
                ZStack {
                    if !focussed {
                        HStack {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
                                    .foregroundStyle(.primary.opacity(0.75))
                                Text("Search")
                                    .foregroundStyle(.primary.opacity(0.75))
                                
                            }
                            .onTapGesture {
                                withAnimation(.bouncy) {
                                    selectedTab = 0
                                }
                            }
                            .padding(5)
                            .background {
                                if selectedTab == 0 {
                                        RoundedRectangle(cornerRadius: 100)
                                        .fill(.gray.opacity(0.25))
                                            .stroke(.gray.opacity(0.5), lineWidth: 5)
                                            .blur(radius: 7.5)
                                }
                            }
                            HStack {
                                Image(systemName: "gear")
                                    .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
                                    .foregroundStyle(.primary.opacity(0.75))
                                
                                Text("Settings")
                                    .foregroundStyle(.primary.opacity(0.75))
                                
                            }
                            .onTapGesture {
                                withAnimation(.bouncy) {
                                    selectedTab = 1
                                }
                            }
                            .padding(5)
                            .background {
                                if selectedTab == 1 {
                                        RoundedRectangle(cornerRadius: 100)
                                        .fill(.gray.opacity(0.25))
                                            .stroke(.gray.opacity(0.5), lineWidth: 5)
                                            .blur(radius: 7.5)
                                }
                                
                            }
                        }
                        .padding(7.5)
                        .background(
                            RoundedRectangle(cornerRadius: 100)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(.ultraThinMaterial, lineWidth: 1)
                                .blur(radius: 1)
                        )
                    }
                    
                    
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
