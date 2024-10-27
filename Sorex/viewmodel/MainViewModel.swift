import AppKit
import UniformTypeIdentifiers

class MainViewModel: ObservableObject {
    let db = SQLiteDatabase()
    let dbUiType = UTType(filenameExtension: "db")!
    @Published private var currentPath: String?
    
    func openFile(_ path: String) {
        print("Opening file \(path)")
        db.openDb(path)
        currentPath = path
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
        
        if let path = p.runModal() == .OK ? p.url?.path() : nil {
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
        
        if let path = p.runModal() == .OK ? p.url?.path() : nil {
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
    
    func getTags() -> [String] {
        return db.getTags()
    }
    
    func getNotes() -> [Note] {
        return db.getNotes()
    }
    
    func searchByTag(_ tag: String) -> [Note] {
        return db.searchByTag(tag)
    }
    
    func _debug() {
        // db.?
    }
}
