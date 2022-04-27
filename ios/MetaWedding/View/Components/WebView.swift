//
//  WebView.swift
//  MetaWedding
//
//  Created by Лев Бакланов on 18.04.2022.
//
 
import SwiftUI
import WebKit
 
struct WebView: UIViewRepresentable {
 
    let htmlString: String
 
    let onResult: (UIViewPrintFormatter) -> ()
 
    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        let navigation = webview.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
        webview.navigationDelegate = context.coordinator
        context.coordinator.setNavigation(navigation: navigation)
        return webview
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        print("updating webview, is loading: \(webView.isLoading)")
    }
 
    func makeCoordinator() -> Coordinator {
        Coordinator(onResult: onResult)
    }
 
    class Coordinator: NSObject, WKNavigationDelegate {
 
        let onResult: (UIViewPrintFormatter) -> ()
        private var navigation: WKNavigation?
 
        init(onResult: @escaping (UIViewPrintFormatter) -> ()) {
            self.onResult = onResult
        }
 
        func setNavigation(navigation: WKNavigation?) {
            self.navigation = navigation
        }
 
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("webview did finish, is old nav nil: \(self.navigation == nil)")
            guard let waitingNav = self.navigation else {
                return
            }
            print("is navigations equal: \(waitingNav == navigation)")
            guard waitingNav == navigation else {
                return
            }
            let formatter = webView.viewPrintFormatter()
            onResult(formatter)
        }
    }
}
