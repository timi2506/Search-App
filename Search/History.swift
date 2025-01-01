import Foundation
import Combine

// HistoryItem Model
struct HistoryItem: Codable, Identifiable, Equatable {
    let id: UUID
    let url: URL
    let searchEngine: String
    let time: Date
    let searchText: String
    
    init(id: UUID = UUID(), url: URL, searchEngine: String, time: Date, searchText: String) {
        self.id = id
        self.url = url
        self.searchEngine = searchEngine
        self.time = time
        self.searchText = searchText
    }
}

// HistoryManager as ObservableObject
class HistoryManager: ObservableObject {
    @Published var historyItems: [HistoryItem] = []
    private let storageKey = "historyItems"
    private var cancellables = Set<AnyCancellable>()
    
    static let shared = HistoryManager()
    
    private init() {
        loadHistory()
        
        // Automatically save history when it changes
        $historyItems
            .sink { [weak self] items in
                self?.saveHistory(items)
            }
            .store(in: &cancellables)
    }
    
    func addHistoryItem(_ item: HistoryItem) {
        DispatchQueue.main.async {
            self.historyItems.insert(item, at: 0) // Insert at the beginning for latest first
            // Optional: Limit history size to 100 items
            if self.historyItems.count > 100 {
                self.historyItems = Array(self.historyItems.prefix(100))
            }
        }
    }
    
    func deleteHistoryItem(_ item: HistoryItem) {
        DispatchQueue.main.async {
            if let index = self.historyItems.firstIndex(of: item) {
                self.historyItems.remove(at: index)
            }
        }
    }
    
    func clearHistory() {
        DispatchQueue.main.async {
            self.historyItems.removeAll()
        }
    }
    
    func loadHistory() {
        DispatchQueue.global(qos: .background).async {
            guard let data = UserDefaults.standard.data(forKey: self.storageKey) else { return }
            let decoder = JSONDecoder()
            if let items = try? decoder.decode([HistoryItem].self, from: data) {
                DispatchQueue.main.async {
                    self.historyItems = items.sorted(by: { $0.time > $1.time })
                }
            }
        }
    }
    
    func saveHistory(_ items: [HistoryItem]) {
        DispatchQueue.global(qos: .background).async {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(items) {
                UserDefaults.standard.set(data, forKey: self.storageKey)
            }
        }
    }
}
