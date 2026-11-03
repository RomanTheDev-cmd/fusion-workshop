import Cocoa
import WebKit

final class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    var window: NSWindow!
    var webView: WKWebView!
    let dataURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("FusionWorkshop", isDirectory: true).appendingPathComponent("progress.json")

    func applicationDidFinishLaunching(_ notification: Notification) {
        let menu = NSMenu()
        let item = NSMenuItem(); menu.addItem(item)
        let appMenu = NSMenu(); item.submenu = appMenu
        appMenu.addItem(withTitle: "О Мастерской Fusion", action: #selector(showAbout), keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Завершить Мастерскую Fusion", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        let edit = NSMenuItem(); menu.addItem(edit); edit.submenu = NSMenu(title: "Правка")
        for (title, action, key) in [("Отменить", "undo:", "z"), ("Вырезать", "cut:", "x"), ("Копировать", "copy:", "c"), ("Вставить", "paste:", "v"), ("Выбрать всё", "selectAll:", "a")] {
            edit.submenu?.addItem(withTitle: title, action: Selector(action), keyEquivalent: key)
        }
        NSApp.mainMenu = menu
        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "saveProgress")
        let saved = (try? Data(contentsOf: dataURL)).flatMap { try? JSONSerialization.jsonObject(with: $0) } as? [String: Any] ?? [:]
        let json = (try? JSONSerialization.data(withJSONObject: saved)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        config.userContentController.addUserScript(WKUserScript(source: "window.nativeProgress = \(json);", injectionTime: .atDocumentStart, forMainFrameOnly: true))
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.setValue(false, forKey: "drawsBackground")
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1260, height: 860), styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.title = "Мастерская Fusion"
        window.minSize = NSSize(width: 680, height: 520)
        window.contentView = webView
        window.center(); window.makeKeyAndOrderFront(nil)
        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Course") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        NSApp.activate(ignoringOtherApps: true)
    }
    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Мастерская Fusion"
        alert.informativeText = "Практический курс проектирования для FDM.\n16 занятий · 4 контрольных проекта.\nКурс и ваш прогресс хранятся на этом Mac.\nПриложение не проверяет файлы Fusion автоматически."
        alert.runModal()
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "saveProgress", let body = message.body as? [String: Any], JSONSerialization.isValidJSONObject(body) else { return }
        do {
            try FileManager.default.createDirectory(at: dataURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try JSONSerialization.data(withJSONObject: body, options: [.prettyPrinted, .sortedKeys])
            try data.write(to: dataURL, options: .atomic)
        } catch {
            webView.evaluateJavaScript("document.getElementById('save-status').textContent = 'Не удалось сохранить прогресс на Mac';", completionHandler: nil)
        }
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, ["https", "http"].contains(url.scheme ?? "") {
            NSWorkspace.shared.open(url); decisionHandler(.cancel)
        } else { decisionHandler(.allow) }
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
