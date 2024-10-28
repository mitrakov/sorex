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
            CommandGroup(replacing: .systemServices) {} // remove std group from main menu
            CommandGroup(replacing: .appVisibility) {} // remove std group from main menu
            CommandMenu("Filе") {
                Menu("Open Recent") {
                    ForEach(recentFiles, id: \.self) { path in
                        Button(path) {
                            vm.openFile(path)
                            recentFiles = vm.getRecentFiles() // update the menu
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
                }
                Divider()
                Button("Close File") {
                    vm.closeFile()
                }
                Divider()
                Button("DEBUG (rm recentFiles)") {
                    vm._debug()
                }
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async {
            if let menu = NSApplication.shared.mainMenu {
                menu.items.removeAll{ $0.title == "File" }
                //menu.items.removeAll{ $0.title == "Edit" } TODO: emojis
                menu.items.removeAll{ $0.title == "View" }
                menu.items.removeAll{ $0.title == "Window" }
                menu.items.removeAll{ $0.title == "Help" }
            }
        }
    }
}
