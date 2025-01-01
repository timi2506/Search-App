import SwiftUI

struct HistorySheet: View {
    @ObservedObject private var historyManager = HistoryManager.shared
    @State private var showHistory = true
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("History")) {
                        DisclosureGroup("Hide History", isExpanded: $showHistory) {
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
                }
                .listStyle(InsetGroupedListStyle())
                
                // Clear History Button
                Button(action: {
                    historyManager.clearHistory()
                }) {
                    Text("Clear History")
                        .foregroundColor(.red)
                }
                .padding()
            }
            .navigationTitle("Search History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton() // Adds the Edit button
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
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
