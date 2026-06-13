import Cocoa
import FlutterMacOS
import WebKit

private let checkoutWebViewType = "egomap/checkout-webview"

final class CheckoutWebViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withViewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> NSView {
    let params = args as? [String: Any]
    let url = params?["url"] as? String ?? ""

    return CheckoutWebView(
      frame: .zero,
      viewId: viewId,
      messenger: messenger,
      initialUrl: url
    )
  }

  func createArgsCodec() -> (FlutterMessageCodec & NSObjectProtocol)? {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

final class CheckoutWebView: NSView, WKNavigationDelegate {
  private let webView: WKWebView
  private let channel: FlutterMethodChannel

  init(
    frame: CGRect,
    viewId: Int64,
    messenger: FlutterBinaryMessenger,
    initialUrl: String
  ) {
    channel = FlutterMethodChannel(
      name: "egomap/checkout_webview/\(viewId)",
      binaryMessenger: messenger
    )

    let configuration = WKWebViewConfiguration()
    webView = WKWebView(frame: frame, configuration: configuration)

    super.init(frame: frame)

    webView.navigationDelegate = self
    webView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(webView)

    NSLayoutConstraint.activate([
      webView.topAnchor.constraint(equalTo: topAnchor),
      webView.leadingAnchor.constraint(equalTo: leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: trailingAnchor),
      webView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterMethodNotImplemented)
        return
      }

      switch call.method {
      case "reload":
        if let url = call.arguments as? String, let target = URL(string: url) {
          self.webView.load(URLRequest(url: target))
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    if let url = URL(string: initialUrl) {
      webView.load(URLRequest(url: url))
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func notifyNavigation(url: String?) {
    guard let url else {
      return
    }

    channel.invokeMethod("navigation", arguments: ["url": url])
  }

  func webView(
    _ webView: WKWebView,
    decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
  ) {
    let url = navigationAction.request.url?.absoluteString
    notifyNavigation(url: url)

    if let url, url.contains("billing/app-return") {
      decisionHandler(.cancel)
      return
    }

    decisionHandler(.allow)
  }

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    notifyNavigation(url: webView.url?.absoluteString)
  }

  func webView(
    _ webView: WKWebView,
    didFailProvisionalNavigation navigation: WKNavigation!,
    withError error: Error
  ) {
    channel.invokeMethod("loadError", arguments: ["message": error.localizedDescription])
  }

  func webView(
    _ webView: WKWebView,
    didFail navigation: WKNavigation!,
    withError error: Error
  ) {
    channel.invokeMethod("loadError", arguments: ["message": error.localizedDescription])
  }
}

private func registerCheckoutWebViewFactory(with controller: FlutterViewController) {
  let registrar = controller.registrar(forPlugin: "EgoMapCheckoutWebView")
  let factory = CheckoutWebViewFactory(messenger: registrar.messenger)
  registrar.register(factory, withId: checkoutWebViewType)
}

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()

    RegisterGeneratedPlugins(registry: flutterViewController)
    registerCheckoutWebViewFactory(with: flutterViewController)

    let windowFrame = frame
    contentViewController = flutterViewController
    setFrame(windowFrame, display: true)

    super.awakeFromNib()
  }
}
