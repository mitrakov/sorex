import SwiftUI

let recentFilesKey = "RECENT_FILES"

// bug: performace of ScrollView
@main
struct sorexApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate // remove standard MacOS menu items (https://stackoverflow.com/a/70553784/2212849)
    private let vm = MainViewModel()
    @State private var recentFiles = UserDefaults.standard.stringArray(forKey: recentFilesKey) ?? [] // don't use @AppStorage because it cannot decode arrays

    var body: some Scene {
        WindowGroup {
            MainView().environmentObject(vm)
        }
        .commands {
            CommandGroup(replacing: .systemServices) {} // rm "sorex  -> Services"
            CommandGroup(replacing: .appVisibility) {}  // rm "sorex  -> Hide, Hide Others, Show All"
            CommandGroup(replacing: .saveItem) {}       // rm "File   -> Close"
            CommandGroup(replacing: .sidebar) {}        // rm "View   -> Enter Full Screen"
            CommandGroup(replacing: .windowSize) {}     // rm "Window -> Minimize, Zoom"
            CommandGroup(replacing: .windowList) {}     // rm "Window -> Bring All to Front"
            CommandGroup(replacing: .help) {}           // rm "Help   -> App Help"
            CommandGroup(replacing: .newItem) {
                Menu("Open Recent") {
                    ForEach(recentFiles, id: \.self) { path in
                        Button(path) {
                            vm.openFile(path)
                            updateMenu()
                        }
                    }
                }
                Divider()
                Button("New File...") {
                    vm.newFile()
                    updateMenu()
                }
                Button("Open...") {
                    vm.openFile()
                    updateMenu()
                }
                Divider()
                Button("Close File") {
                    vm.closeFile()
                }
            }
        }
    }

    private func updateMenu() {
        recentFiles = vm.getRecentFiles()
        AppDelegate.removeViewWindowHelpMenu()
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.removeViewWindowHelpMenu()
    }

    static func removeViewWindowHelpMenu() {
        DispatchQueue.main.async {
            if let menu = NSApplication.shared.mainMenu {
                menu.items.removeAll{ $0.title == "View" }
                menu.items.removeAll{ $0.title == "Window" }
                menu.items.removeAll{ $0.title == "Help" }
            }
        }
    }
}
