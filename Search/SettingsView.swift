import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedEngine") var selectedEngine = 0
    @AppStorage("Search-Prefix") var searchPrefix = "https://google.com/search?q="
    @AppStorage("Search Engine") var searchEngine = "Google"
    @State private var historyItems: [HistoryItem] = []
    @State private var showHistoryItem = false
    @AppStorage("selectedHistoryItem") var urlToDisplay = URL(string: "example.com")!
    @AppStorage("privateMode") var privateMode = false
    @ObservedObject private var historyManager = HistoryManager.shared

    var body: some View {
            List {
                Section("Search Engine") {
                    Picker("Search Engine", selection: $selectedEngine) {
                        Text("Google")
                            .tag(0)
                        Text("Bing")
                            .tag(1)
                        Text("Yahoo!")
                            .tag(2)
                        Text("DuckDuckGo")
                            .tag(3)
                        Text("Ecosia")
                            .tag(4)
                        Text("Custom")
                            .tag(5)
                    }
                }
                .onChange(of: selectedEngine) { oldValue, newValue in
                    if selectedEngine == 0 {
                        searchPrefix = "https://google.com/search?q="
                        searchEngine = "Google"
                    }
                    if selectedEngine == 1 {
                        searchPrefix = "https://bing.com/search?q="
                        searchEngine = "Bing"
                    }
                    if selectedEngine == 2 {
                        searchPrefix = "https://search.yahoo.com/search?p="
                        searchEngine = "Yahoo!"
                    }
                    if selectedEngine == 3 {
                        searchPrefix = "https://duckduckgo.com/?q="
                        searchEngine = "DuckDuckGo"
                    }
                    if selectedEngine == 4 {
                        searchPrefix = "https://www.ecosia.org/search?q="
                        searchEngine = "Ecosia"
                    }
                    if selectedEngine == 4 {
                        searchPrefix = "https://www.ecosia.org/search?q="
                        searchEngine = "Custom"
                    }
                    
                }
                if selectedEngine == 5 {
                    Section("Custom") {
                        VStack {
                            TextField ("Custom Search Prefix", text: $searchPrefix)
                                .textContentType(.URL)
                                .keyboardType(.URL)
                            Text("For a search engine not included in this list (e.g., YouTube), enter a custom search prefix. This is an example for the Google Search Prefix: \"https://google.com/search?q=\". The prefix format may vary depending on the search engine.")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                    }
                }
                Section(header: Text("History")) {
                    DisclosureGroup("Show History") {
                        if historyManager.historyItems.isEmpty {
                            Text("No history items available.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(historyManager.historyItems) { item in
                                HStack {
                                    // Show search engine favicon
                                    AsyncImage(url: getFavicon(for: item.searchEngine)) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                                .cornerRadius(5)
                                        } else if phase.error != nil {
                                            Image(systemName: "questionmark.circle")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(.gray)
                                        } else {
                                            ProgressView()
                                                .frame(width: 50, height: 50)
                                        }
                                    }

                                    VStack(alignment: .leading) {
                                        Text(item.searchText)
                                            .font(.headline)
                                        Text("\(item.searchEngine) • \(item.url.absoluteString)")
                                            .font(.subheadline)
                                        Text(item.time, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: deleteHistoryItems) // Enable delete functionality
                        }
                    }
                }
                Section("Private Mode"){
                        HStack {
                            if privateMode {
                                Image(systemName: "eyes.inverse")
                                .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
                            }
                            else {
                                Image(systemName: "eyes")
                                    .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
                                
                            }
                            Toggle("Enable Private Mode", isOn: $privateMode)
                        }
                        Text("Disables saving search results to history")
                            .font(.caption)
                            .foregroundStyle(.gray)
                }
            }
            .cornerRadius(15)
            .sheet(isPresented: $showHistoryItem) {
                if let validURL = URL(string: urlToDisplay.absoluteString) {
                    SafariView(url: validURL)
                } else {
                    Text("Invalid URL")
                }
            }
            
        }
    func loadHistory() {
        if let savedData = UserDefaults.standard.data(forKey: "historyItems"),
           let savedHistory = try? JSONDecoder().decode([HistoryItem].self, from: savedData) {
            historyItems = savedHistory
        } else {
            historyItems = [] // If no saved data, initialize an empty array
        }
    }
    // MARK: - Delete History Items
    private func deleteHistoryItems(at offsets: IndexSet) {
        offsets.map { historyManager.historyItems[$0] }.forEach { item in
            historyManager.deleteHistoryItem(item)
        }
    }
    // MARK: - Helper to Get Favicon URL
    private func getFavicon(for searchEngine: String) -> URL? {
        switch searchEngine {
        case "Google":
            return URL(string: "https://google.com/favicon.ico")
        case "Yahoo!":
            return URL(string: "https://yahoo.com/favicon.ico")
        case "Bing":
            return URL(string: "https://bing.com/favicon.ico")
        case "DuckDuckGo":
            return URL(string: "https://duckduckgo.com/favicon.ico")
        case "Ecosia":
            return URL(string: "https://ecosia.com/favicon.ico")
        default:
            return nil
        }
    }
}


