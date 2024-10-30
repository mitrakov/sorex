import SwiftUI

let recentFilesKey = "RECENT_FILES"

@main
struct sorexApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate // remove standard MacOS menu items (https://stackoverflow.com/a/70553784/2212849)
    let vm = MainViewModel()
    @State private var recentFiles = UserDefaults.standard.stringArray(forKey: recentFilesKey) ?? []
    
    var body: some Scene {
        WindowGroup {
            MainView(vm: vm)
        }
        .commands {
            Group {
                CommandGroup(replacing: .appSettings) {}
                CommandGroup(replacing: .systemServices) {}
                CommandGroup(replacing: .appVisibility) {}
                CommandGroup(replacing: .saveItem) {}
                CommandGroup(replacing: .importExport) {}
                CommandGroup(replacing: .printItem) {}
                CommandGroup(replacing: .textEditing) {}
            }
            Group {
                CommandGroup(replacing: .toolbar) {}
                CommandGroup(replacing: .sidebar) {}
                CommandGroup(replacing: .windowSize) {}
                CommandGroup(replacing: .windowList) {}
                CommandGroup(replacing: .singleWindowList) {}
                CommandGroup(replacing: .windowArrangement) {}
                CommandGroup(replacing: .help) {}              // rm Help -> sorexHelp
            }
            CommandGroup(replacing: .newItem) {
                Menu("Open Recent") {
                    ForEach(recentFiles, id: \.self) { path in
                        Button(path) {
                            vm.openFile(path)
                            recentFiles = vm.getRecentFiles() // update the menu
                            AppDelegate.removeViewWindowHelpMenu()
                        }
                    }
                }
                Divider()
                Button("New File") {
                    vm.newFile()
                }
                Button("Open...") {
                    vm.openFile()
                    recentFiles = vm.getRecentFiles() // update the menu
                    AppDelegate.removeViewWindowHelpMenu()
                }
                Divider()
                Button("Close File") {
                    vm.closeFile()
                }
            }
        }
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
