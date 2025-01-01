import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    @AppStorage("selectedHistoryItem") var url = URL(string: "example.com")!

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // SafariView does not support dynamic updates.
        // You would need to dismiss and re-present if the URL changes.
    }
}
