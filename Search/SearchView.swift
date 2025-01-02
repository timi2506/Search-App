import SwiftUI
import WebKit
import HapticEase

struct SearchView: View {
    @State private var searchText: String = ""
    @FocusState private var closeKeyboard: Bool
    @State private var searchFinished: Bool = false
    @Binding var focussed: Bool // Reintroduced 'focussed' state
    @AppStorage("Search-Prefix") private var searchPrefix: String = "https://google.com/search?q="
    @AppStorage("Search Engine") private var searchEngine: String = "Google"
    @AppStorage("selectedEngine") private var selectedEngine: Int = 0
    @AppStorage("privateMode") private var privateMode: Bool = false
    @State private var historySheet: Bool = false
    @ObservedObject private var historyManager: HistoryManager = HistoryManager.shared
    @State private var currentlyLoadedURL: URL? = nil // Correctly declared as Optional

    var body: some View {
        ZStack {
            VStack {
                // Header
                HStack {
                    if #available(iOS 18.0, *) {
                        Image(systemName: "magnifyingglass")
                            .symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 3.0)))
                    } else {
                        Image(systemName: "magnifyingglass")
                    }
                    Text("Search")
                }
                .font(.title)
                .bold()
                
                // Search Field
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .onTapGesture {
                                HapticFeedback()
                                    .selection()
                                privateMode = true
                            }
                        
                        TextField("Search \(searchEngine)", text: $searchText, onEditingChanged: { editingChanged in
                            focussed = editingChanged // Update 'focussed' state
                        }, onCommit: {
                            focussed = false
                            performSearch()
                        })
                        .focused($closeKeyboard)
                        .textFieldStyle(PlainTextFieldStyle())
                        
                        Image(systemName: "clock")
                            .onTapGesture {
                                HapticFeedback()
                                    .selection()
                                historySheet = true
                            }
                        Image(systemName: "eyes")
                            .onTapGesture {
                                HapticFeedback()
                                    .pulsePattern()
                                privateMode = true
                            }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(.gray.opacity(0.25), lineWidth: 5)
                                .blur(radius: 5)
                        )
                )
                    .padding()
                
                // WebView or Search Results
                if searchFinished, !searchText.isEmpty, !focussed { // Using 'focussed' state
                    searchWebView
                }
            }
            .onChange(of: closeKeyboard) { newValue in
                if newValue {
                    searchFinished = false
                }
            }
        }
        .sheet(isPresented: $historySheet) {
            HistorySheet()
        }
    }
    
    
    
    // MARK: - Search WebView
    private var searchWebView: some View {
        VStack {
            headerWithMenu
            iOSWebView(
                url: webViewSearchURL,
                currentURL: $currentlyLoadedURL
            )
            .ignoresSafeArea(.all)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(.ultraThinMaterial, lineWidth: 2.5)
            )
            .cornerRadius(15)
        }
    }
    
    // MARK: - Header with Menu
    private var headerWithMenu: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.gray)
                    Text("Back to search results page")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .frame(alignment: .center)
                }
                .onTapGesture {
                    searchFinished = false
                }
                
                Spacer()
                
                Menu("Options") {
                    Button("Open Search in Browser", systemImage: "safari") {
                        UIApplication.shared.open(webViewSearchURL)
                    }
                    
                    ShareLink(item: webViewSearchURL) {
                        Label("Share Search", systemImage: "square.and.arrow.up")
                    }
                    
                    Button("History", systemImage: "clock") {
                        historySheet = true
                    }
                }
                .font(.caption)
            }
            .padding(5)
            
            Text("Search results for: \(searchText)")
                .font(.caption)
        }
        .padding()
    }
    
    // MARK: - Perform Search
    private func performSearch() {
        searchFinished = true
        HapticFeedback()
            .heartbeatPattern()
        addHistoryItem()
    }
    
    // MARK: - Add History Item
    private func addHistoryItem() {
        guard !searchText.isEmpty,
              let url = URL(string: searchPrefix + searchText) else {
            print("Invalid search input")
            return
        }
        
        let newHistoryItem = HistoryItem(
            url: url,
            searchEngine: searchEngine, // Accessing 'searchEngine' directly
            time: Date(),
            searchText: searchText
        )
        
        print("Adding history item with searchEngine: \(searchEngine)")
        historyManager.addHistoryItem(newHistoryItem)
    }
    
    // MARK: - Computed Property for WebView URL
    private var webViewSearchURL: URL {
        URL(string: searchPrefix + searchText) ?? URL(string: "https://example.com")!
    }
}
