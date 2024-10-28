import AppKit
import UniformTypeIdentifiers

class MainViewModel: ObservableObject {
    let db = SQLiteDatabase()
    let dbUiType = UTType(filenameExtension: "db")!
    @Published private var currentPath: String? // for updating parent Views
    
    func openFile(_ path: String) {
        print("Opening file \(path)")
        db.openDb(path)
        updateRecentFilesList(path)
        currentPath = path
        // TODO: if file not found, rm from RecentFiles list
    }
    
    func openFile() {
        let p = NSOpenPanel() // don't use .fileImporter here because of lack of settings
        p.allowedContentTypes = [dbUiType]
        p.allowsMultipleSelection = false
        p.canChooseFiles = true
        p.canChooseDirectories = false
        p.isExtensionHidden = false
        p.allowsOtherFileTypes = false
        p.message = "Select a DB file"
        
        if let path = p.runModal() == .OK ? p.url?.path(percentEncoded: false) : nil { // "percentEncoded: false" allows diacriticals
            self.openFile(path)
        }
    }
    
    func newFile() {
        let p = NSSavePanel() // don't use fileExporter here because of lack of settings
        p.allowedContentTypes = [dbUiType]
        p.canCreateDirectories = true
        p.isExtensionHidden = false
        p.allowsOtherFileTypes = false
        p.showsTagField = false
        p.title = "New DB file"
        p.message = "Create a new DB file"
        p.nameFieldLabel = "DB name:"
        p.nameFieldStringValue = "mydb"
        
        if let path = p.runModal() == .OK ? p.url?.path(percentEncoded: false) : nil { // "percentEncoded: false" allows diacriticals
            // TODO: bug table note already exists (code: 1) (when re-write the file)
            print("Creating file \(path)")
            db.createDb(path)
            currentPath = path
        }
    }
    
    func closeFile() {
        db.closeDb()
        currentPath = nil
    }
    
    func getRecentFiles() -> [String] {
        UserDefaults.standard.stringArray(forKey: recentFilesKey) ?? []
    }
    
    func getTags() -> [String] {
        return db.getTags()
    }
    
    func getNotes() -> [Note] {
        return db.getNotes()
    }
    
    func searchByTag(_ tag: String) -> [Note] {
        return db.searchByTag(tag)
    }
    
    private func updateRecentFilesList(_ newItem: String) {
        var array = getRecentFiles()
        if let idx = array.firstIndex(of: newItem) {
            array.remove(at: idx)
        }
        array = [newItem] + array
        UserDefaults.standard.set(array, forKey: recentFilesKey)
    }
    
    func _debug() {
        UserDefaults.standard.removeObject(forKey: recentFilesKey)
    }
}
