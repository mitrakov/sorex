import AppKit
import UniformTypeIdentifiers

open class Utils {
    static func showAlert(_ title: String, _ text: String, _ style: NSAlert.Style = .informational) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = style
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    static func showYesNoDialog(_ title: String, _ text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        
        return alert.runModal().rawValue == 1000 // 1000 = Yes
    }
    
    static func showOpenFileDialog(_ message: String, _ allowedExtensions: [String]) -> String? {
        let p = NSOpenPanel() // don't use .fileImporter here because of lack of settings
        p.allowedContentTypes = allowedExtensions.map {UTType(filenameExtension: $0)!}
        p.allowsMultipleSelection = false
        p.canChooseFiles = true
        p.canChooseDirectories = false
        p.isExtensionHidden = false
        p.allowsOtherFileTypes = false
        p.message = message

        return p.runModal() == .OK ? p.url?.path : nil
    }
    
    static func showSaveFileDialog(title: String, message: String, nameLabel: String, defaultName: String, _ allowedExtensions: [String]) -> String? {
        let p = NSSavePanel() // don't use fileExporter here because of lack of settings
        p.allowedContentTypes = allowedExtensions.map {UTType(filenameExtension: $0)!}
        p.canCreateDirectories = true
        p.isExtensionHidden = false
        p.allowsOtherFileTypes = false
        p.showsTagField = false
        p.title = title
        p.message = message
        p.nameFieldLabel = "\(nameLabel):"
        p.nameFieldStringValue = defaultName
        
        return p.runModal() == .OK ? p.url?.path : nil
    }
    
    static func splitStringBy(_ s: String, _ separator: String) -> [String] {
        s.components(separatedBy: separator).map {$0.trimmingCharacters(in: .whitespaces)}.filter {!$0.isEmpty}
    }
}
