import SwiftUI
import WebKit

struct iOSWebView: UIViewRepresentable {
    let url: URL
    @Binding var currentURL: URL?
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        webView.isOpaque = false // Make WebView transparent
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.configuration.preferences.javaScriptEnabled = true
        webView.navigationDelegate = context.coordinator
        
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            uiView.load(URLRequest(url: url))
        }
        
        // Inject JavaScript to ensure the page background is transparent
        let js = """
        document.body.style.backgroundColor = 'transparent';
        """
        uiView.evaluateJavaScript(js, completionHandler: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: iOSWebView
        
        init(_ parent: iOSWebView) {
            self.parent = parent
        }
        
        // Capture the current URL when navigation finishes
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.currentURL = webView.url
        }
        
        // Update the current URL before navigation starts
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                parent.currentURL = url
            }
            decisionHandler(.allow)
        }
        
        // Handle navigation failures
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView navigation failed with error: \(error.localizedDescription)")
        }
    }
}
