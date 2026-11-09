import Flutter
import Foundation
import UIKit

/// Bridge implementation for common native APIs
class CommonBridge: NSObject, NativeCommon {
    private let viewController: UIViewController?
    /// 保留强引用，避免 UIDocumentInteractionController 被提前释放
    private var documentInteractionController: UIDocumentInteractionController?

    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
        super.init()
    }

    func startActivityFromUri(intentUri: String) throws -> Bool {
        print("[CommonBridge] startActivityFromUri: \(intentUri)")

        guard let url = URL(string: intentUri) else {
            print("[CommonBridge] Invalid URL: \(intentUri)")
            return false
        }

        // Check if the URL can be opened
        guard UIApplication.shared.canOpenURL(url) else {
            print("[CommonBridge] Cannot open URL: \(intentUri)")
            return false
        }

        // Open the URL
        UIApplication.shared.open(url, options: [:]) { success in
            print("[CommonBridge] Open URL result: \(success)")
        }

        return true
    }

    /// 用系统预览器（Quick Look）打开本地文件，无需任何权限
    func openFileWithViewer(path: String) throws -> Bool {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path) else {
            print("[CommonBridge] openFileWithViewer: file not found \(path)")
            return false
        }
        let url = URL(fileURLWithPath: path)
        DispatchQueue.main.async { [weak self] in
            let controller = UIDocumentInteractionController(url: url)
            controller.delegate = self
            controller.presentPreview(animated: true)
            self?.documentInteractionController = controller
        }
        return true
    }
    
    func getDeviceSdkInt() throws -> Int64 {
        // iOS doesn't have SDK int like Android, return iOS major version
        let systemVersion = UIDevice.current.systemVersion
        let majorVersion = systemVersion.components(separatedBy: ".").first ?? "0"
        let version = Int64(majorVersion) ?? 0
        print("[CommonBridge] Device iOS version: \(version)")
        return version
    }
    
    func getDeviceCPUABI() throws -> String {
        // Get CPU architecture
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        print("[CommonBridge] Device CPU ABI: \(identifier)")
        return identifier
    }
    
    func getVersionName() throws -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        print("[CommonBridge] Version name: \(version)")
        return version
    }
    
    func getVersionCode() throws -> Int64 {
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        let code = Int64(build) ?? 1
        print("[CommonBridge] Version code: \(code)")
        return code
    }
    
    func toast(msg: String) throws {
        print("[CommonBridge] Toast: \(msg)")
        showToast(message: msg, duration: 2.0)
    }
    
    func longToast(msg: String) throws {
        print("[CommonBridge] Long toast: \(msg)")
        showToast(message: msg, duration: 4.0)
    }
    
    // MARK: - Toast Helper
    
    private func showToast(message: String, duration: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
                print("[CommonBridge] No key window found for toast")
                return
            }
            
            let toastLabel = UILabel()
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center
            toastLabel.font = UIFont.systemFont(ofSize: 14)
            toastLabel.text = message
            toastLabel.alpha = 0.0
            toastLabel.layer.cornerRadius = 10
            toastLabel.clipsToBounds = true
            toastLabel.numberOfLines = 0
            
            let maxSize = CGSize(width: window.frame.width - 80, height: window.frame.height)
            let expectedSize = toastLabel.sizeThatFits(maxSize)
            toastLabel.frame = CGRect(
                x: (window.frame.width - expectedSize.width - 20) / 2,
                y: window.frame.height - 150,
                width: expectedSize.width + 20,
                height: expectedSize.height + 20
            )
            
            window.addSubview(toastLabel)
            
            UIView.animate(withDuration: 0.3, animations: {
                toastLabel.alpha = 1.0
            }) { _ in
                UIView.animate(withDuration: 0.3, delay: duration, options: [], animations: {
                    toastLabel.alpha = 0.0
                }) { _ in
                    toastLabel.removeFromSuperview()
                }
            }
        }
    }
}

// MARK: - UIDocumentInteractionControllerDelegate
extension CommonBridge: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(
        _ controller: UIDocumentInteractionController
    ) -> UIViewController {
        viewController ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
            ?? UIViewController()
    }
}
