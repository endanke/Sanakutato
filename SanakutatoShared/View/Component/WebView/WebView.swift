// Source: https://github.com/kylehickinson/SwiftUI-WebView

import SwiftUI
import WebKit
import Combine

struct WebView: Representable {

    @ObservedObject var viewModel: WebViewModel

    #if os(macOS)
    func makeNSView(context: Context) -> WKWebView { return makeView(context: context) }
    func updateNSView(_ nsView: WKWebView, context: Context) { updateView(nsView, context: context) }
    #else
    func makeUIView(context: Context) -> WKWebView { return makeView(context: context) }
    func updateUIView(_ uiView: WKWebView, context: Context) { updateView(uiView, context: context) }
    #endif

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeView(context: Context) -> WKWebView {
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

    func updateView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: viewModel.url), webView.url != url {
            print("Loading url")
            webView.load(URLRequest(url: url))
        } else if let htmlResource = viewModel.htmlResource {
            webView.loadHTMLString(htmlResource, baseURL: nil)
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {

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
            guard let monitoredResourceURL = self.parent.viewModel.monitoredResourceURL else { return }
            if let dict = message.body as? [String: AnyObject],
                let status = dict["status"] as? Int,
                let responseUrl = dict["responseURL"] as? String {
                if status == 200 && responseUrl.starts(with: monitoredResourceURL) {
                    webView?.evaluateJavaScript(
                        "document.body.innerHTML",
                        completionHandler: { (value: Any?, _: Error!) -> Void in
                        if let content = value as? String {
                            self.parent.viewModel.resourceLoaded(content: content)
                        }
                    })
                }
            }
        }

    }
}
