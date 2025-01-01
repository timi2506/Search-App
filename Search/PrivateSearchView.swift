import SwiftUI
import WebKit
import LocalAuthentication

struct PrivateSearchView: View {
    @State private var searchText = ""
    @FocusState var closeKeyboard: Bool
    @Binding var focussed: Bool
    @State private var searchFinished = false
    @AppStorage("Search-Prefix") var searchPrefix = "https://google.com/search?q="
    @AppStorage("Search Engine") var searchEngine = "Google"
    @State private var historySheet = false
    @AppStorage("privateMode") var privateMode = false
    @State var showDisableAnim = false
    @State var showEnableAnim = false
    @State private var isUnlocked = false

    var body: some View {
        

        if !isUnlocked {
            VStack {
                Image(systemName: "lock.fill")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                Text("Private Mode is Locked")
                    .font(.title)
                    .bold()
                Text("Please unlock Private Mode to continue")
                    .font(.headline)
                Spacer()
                Button("Unlock", systemImage: "lock.open.fill") {
                    authenticate()
                }
                    .padding()
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 100)
                            .fill(.blue)
                    )
            }
            .onAppear(perform: authenticate)

        }
        else {
            ZStack {
                VStack {
                    HStack {
                        Image(systemName: "eyes")
                            .symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 3.0)))
                        Text("Private Search")
                        
                    }
                    .font(.title)
                    .bold()
                    VStack {
                        HStack {
                            Image(systemName: "eyes.inverse")
                                .onTapGesture {
                                    privateMode = false
                                }
                            TextField("Search \(searchEngine) in Private", text: $searchText, onEditingChanged: { (editingChanged) in
                                if editingChanged {
                                    focussed = true
                                } else {
                                    focussed = false
                                }
                            }, onCommit: {
                                focussed = false
                                searchFinished = true
                            })
                            .focused($closeKeyboard)
                            .textFieldStyle(PlainTextFieldStyle())
                            Image(systemName: "lock.fill")
                                .onTapGesture {
                                    isUnlocked = false
                                    privateMode = false
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
                    if searchFinished {
                        if searchText != "" {
                            if !focussed {
                                // Search WebView her
                                @State var WebViewSearchURL = URL(string: searchPrefix + searchText)!
                                let url = WebViewSearchURL
                                ZStack {
                                    VStack {
                                        HStack {
                                            VStack {
                                                HStack {
                                                    Image(systemName: "chevron.left")
                                                        .foregroundStyle(.gray)
                                                    
                                                    Text("Back to search results file")
                                                        .font(.caption)
                                                        .foregroundStyle(.gray)
                                                        .frame(alignment: .center)
                                                    Spacer()
                                                    Menu("Options") {
                                                        Button("Open Search in Browser", systemImage: "safari") {
                                                            UIApplication.shared.open(WebViewSearchURL)
                                                        }
                                                        ShareLink (item: WebViewSearchURL){
                                                            Label("Share Search", systemImage: "square.and.arrow.up")
                                                        }
                                                        Button("History", systemImage: "clock") {
                                                            historySheet = true
                                                        }
                                                        .disabled(true)
                                                    }
                                                    .font(.caption)
                                                }
                                                .onTapGesture {
                                                    searchFinished = false
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                                                        WebViewSearchURL = URL(string: searchPrefix + searchText)!
                                                        searchFinished = true
                                                    })
                                                }
                                                .frame(alignment: .leading)
                                                .padding(2.5)
                                                Text("Search results for: \(searchText)")
                                                    .font(.caption)
                                                    .frame(alignment: .center)
                                            }
                                            
                                        }
                                        .padding(5)
                                        PRIVATEiOSWebView(
                                            url: url
                                        )
                                        
                                    }
                                    .ignoresSafeArea(.all)
                                    .overlay (
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(.ultraThinMaterial, lineWidth: 2.5)
                                    )
                                    .cornerRadius(15)
                                }
                                
                            }
                        }
                    }
                }
                .onChange(of: focussed) { oldValue, newValue in
                    if focussed {
                        searchFinished = false
                    }
                }
            }
            
        }

    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {
                    isUnlocked = true
                } else {
                    isUnlocked = false
                }
            }
        } else {
            // no biometrics
        }
    }
}

struct PRIVATEiOSWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
        webView.isOpaque = false // Make WebView transparent
        webView.configuration.preferences.javaScriptEnabled = true
        webView.navigationDelegate = context.coordinator
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)

    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {}
}

