import SwiftUI
import WebKit
import LocalAuthentication
import HapticEase

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
    @State private var biometricsWarning = false
    
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
                    HapticFeedback()
                        .selection()
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
                        if #available(iOS 18.0, *) {
                            Image(systemName: "eyes")
                                .symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 3.0)))
                        }
                        else {
                            Image(systemName: "eyes")
                        }
                        Text("Private Search")
                        
                    }
                    .font(.title)
                    .bold()
                    VStack {
                        HStack {
                            Image(systemName: "eyes.inverse")
                                .onTapGesture {
                                    HapticFeedback()
                                        .selection()
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
                                    HapticFeedback()
                                        .pulsePattern()
                                    privateMode = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                                        isUnlocked = false
                                    })
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

                    if biometricsWarning {
                        HStack {
                            Image("exclamationmark.triangle.fill")
                                .font(.caption)
                            Text("WARNING: FaceID or TouchID are disabled, Private Mode is unprotected")
                                .font(.caption)
                        }
                        .foregroundStyle(.red)
                    }
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
                                .ignoresSafeArea(.all)
                                
                            }
                        }
                    }
                }
                .onChange(of: focussed) { newValue in
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
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate to access the Private Mode"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                        HapticFeedback()
                            .success()
                    } else {
                        isUnlocked = false
                        HapticFeedback()
                            .error()
                    }
                }
            }
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Please authenticate to access the Private Mode"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isUnlocked = true
                        HapticFeedback()
                            .success()
                    } else {
                        isUnlocked = false
                        HapticFeedback()
                            .error()
                    }
                }
            }
        } else {
            isUnlocked = true
            biometricsWarning = true
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

