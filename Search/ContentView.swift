import SwiftUI
import HapticEase

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var focussed = false
    @AppStorage("privateMode") var privateMode = false

    var body: some View {
        NavigationStack {
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
                    
                    ZStack {
                        if !focussed {
                            if selectedTab != 0 {
                                HStack {
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
                                            .foregroundStyle(.primary.opacity(0.75))
                                        Text("Search")
                                            .foregroundStyle(.primary.opacity(0.75))
                                        
                                    }
                                    .onTapGesture {
                                        HapticFeedback()
                                            .selection()
                                        withAnimation(.bouncy) {
                                            selectedTab = 0
                                        }
                                    }
                                    .padding(5)
                                    .background {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 100)
                                                .fill(.gray.opacity(0.10))
                                                .blur(radius: 7.5)
                                            RoundedRectangle(cornerRadius: 100)
                                                .stroke(.gray.opacity(0.25), lineWidth: 3.5)
                                                .blur(radius: 5)
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
            .toolbar {
                if selectedTab != 1 {
                    VStack {
                        Button(action: {
                            HapticFeedback()
                                .selection()
                            withAnimation(.bouncy) {
                                selectedTab = 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "gear")
                                    .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
                                    .foregroundStyle(.primary.opacity(0.75))
                                
                            }
                            .padding(5)
                        }
                        .foregroundStyle(.primary)
                        
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
