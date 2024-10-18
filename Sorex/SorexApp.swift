import SwiftUI

@main
struct sorexApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate // remove standard MacOS menu items (https://stackoverflow.com/a/70553784/2212849)
    let vm = MainViewModel()
    let tmp = [
        "/Volumes/Tommy/Users/tommy/Yandex.Disk.localized/all/db/it.db",
        "/Volumes/Tommy/Users/tommy/Yandex.Disk.localized/all/db/cola.db",
        "/Volumes/Tommy/Users/tommy/Yandex.Disk.localized/all/db/hogar.db",
        "/Volumes/Tommy/Users/tommy/Yandex.Disk.localized/all/db/estadística.db",
        "/Volumes/Tommy/Users/tommy/Yandex.Disk.localized/all/db/resolución.db",
    ]
    
    var body: some Scene {
        WindowGroup {
            MainView(vm: vm)
        }
        .commands {
            CommandGroup(replacing: .systemServices) {}
            CommandGroup(replacing: .appVisibility) {}
            CommandMenu("Filе") {
                Menu("Open Recent") {
                    ForEach(tmp, id: \.self) { path in
                        Button(path) {
                            vm.openFile(path)
                        }
                    }
                }
                Divider()
                Button("New File") {
                    vm.newFile()
                }
                Button("Open...") {
                    vm.openFile()
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
        DispatchQueue.main.async {
            if let menu = NSApplication.shared.mainMenu {
                menu.items.removeAll{ $0.title == "File" }
                menu.items.removeAll{ $0.title == "Edit" }
                menu.items.removeAll{ $0.title == "View" }
                menu.items.removeAll{ $0.title == "Window" }
                menu.items.removeAll{ $0.title == "Help" }
            }
        }
    }
}
