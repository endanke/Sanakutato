// Source: https://github.com/kylehickinson/SwiftUI-WebView

import SwiftUI
import WebKit
import Combine

#if os(macOS)
typealias Representable = NSViewRepresentable
typealias RepresentableContext = NSViewRepresentableContext
#else
typealias Representable = UIViewRepresentable
typealias RepresentableContext = UIViewRepresentableContext
#endif

class ViewModel: ObservableObject {
    @Published var searchText: String = "" {
        didSet {
            url = "https://translate.google.com/#view=home&op=translate&sl=fi&tl=en&text=\(searchText)"
            history.append(searchText)
        }
    }
    @Published var history: [String] = []
    @Published var url: String = ""
    @Published var translatedTerms: [Term] = []
    var searchTerm: Term { return Term(language: .english, text: searchText) }
    var webViewNavigationPublisher = PassthroughSubject<WebViewNavigation, Never>()
    var showLoader = PassthroughSubject<Bool, Never>()
    var valuePublisher = PassthroughSubject<String, Never>()
}

enum WebViewNavigation {
    case backward, forward
}

enum WebUrl {
    case localUrl, publicUrl
}

struct WebView: Representable {

    let wiktionary = WiktionaryApi()
    weak var webView: WKWebView?

    #if os(macOS)

    func makeNSView(context: RepresentableContext<WebView>) -> WKWebView {
        return makeUIView(context: context)
    }

    func updateNSView(_ nsView: WKWebView, context: RepresentableContext<WebView>) {
        updateUIView(nsView, context: context)
    }

    #else

    #endif

    @ObservedObject var viewModel: ViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences

        // Source: https://stackoverflow.com/a/52438332/1960938
        let content = """
        var open = XMLHttpRequest.prototype.open;
        XMLHttpRequest.prototype.open = function() {
            this.addEventListener("load", function() {
                var message = {"status" : this.status, "responseURL" : this.responseURL}
                webkit.messageHandlers.handler.postMessage(message);
            });
            open.apply(this, arguments);
        };
        """
        let script = WKUserScript(source: content, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(script)
        configuration.userContentController.add(context.coordinator, name: "handler")

        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        context.coordinator.webView = webView

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: viewModel.url), webView.url != url {
            print("Loading url")
            webView.load(URLRequest(url: url))
            wiktionary.fetchTranslation(term: viewModel.searchTerm)
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {

        let api = GoogleTranslateApi()
        weak var webView: WKWebView?
        var parent: WebView
        var webViewNavigationSubscriber: AnyCancellable?

        init(_ uiWebView: WebView) {
            self.parent = uiWebView
        }

        deinit {
            webViewNavigationSubscriber?.cancel()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.parent.viewModel.showLoader.send(false)
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            parent.viewModel.showLoader.send(false)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.viewModel.showLoader.send(false)
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.viewModel.showLoader.send(true)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.viewModel.showLoader.send(true)
            self.webViewNavigationSubscriber = self.parent.viewModel
                .webViewNavigationPublisher.receive(on: RunLoop.main)
                .sink(receiveValue: { navigation in
                switch navigation {
                case .backward:
                    if webView.canGoBack {
                        webView.goBack()
                    }
                case .forward:
                    if webView.canGoForward {
                        webView.goForward()
                    }
                }
            })
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }

        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            if let dict = message.body as? [String: AnyObject],
                let status = dict["status"] as? Int,
                let responseUrl = dict["responseURL"] as? String {
                if status == 200 && responseUrl.starts(with: "https://translate.google") {
                    webView?.evaluateJavaScript(
                        "document.body.innerHTML",
                        completionHandler: { (value: Any?, _: Error!) -> Void in
                        if let string = value as? String {
                            self.parent.viewModel.translatedTerms = self.api.parseTerms(input: string)
                        }
                    })
                }
            }
        }

    }
}
