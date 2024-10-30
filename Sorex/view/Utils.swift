import AppKit

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
    
    static func splitStringBy(_ s: String, _ separator: String) -> [String] {
        s.components(separatedBy: separator).map {$0.trimmingCharacters(in: .whitespaces)}.filter {!$0.isEmpty}
    }
}
