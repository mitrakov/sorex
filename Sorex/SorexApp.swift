import SwiftUI

@main
struct sorexApp: App {
    let vm = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView(vm: vm)
        }
        .commands {
            CommandGroup(replacing: .textEditing) {
                Divider()
                Menu("Import/Export") {
                    Button("Open it.db") {
                        vm.openFile("/Users/tommy/Yandex.Disk.localized/all/db/it.db")
                    }
                    Button("Open hogar.db") {
                        vm.openFile("/Users/tommy/Yandex.Disk.localized/all/db/hogar.db")
                    }
                    Button("Open cola.db") {
                        vm.openFile("/Users/tommy/Yandex.Disk.localized/all/db/cola.db")
                    }
                    Button("DEBUG") {
                        vm._debug()
                    }
                }
            }
        }
    }
}
