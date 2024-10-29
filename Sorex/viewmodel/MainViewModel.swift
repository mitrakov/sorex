import AppKit
import UniformTypeIdentifiers

class MainViewModel: ObservableObject {
    private let db = SQLiteDatabase()
    private let dbUiType = UTType(filenameExtension: "db")!
    @Published private var currentPath: String? // for updating parent Views
    
    func openFile(_ path: String) {
        if FileManager.default.fileExists(atPath: path) {
            print("Opening file \(path)")
            db.openDb(path)
            currentPath = path
            addToRecentFilesList(path)
        } else {
            print("File not found: \(path)")
            removeFromRecentFilesList(path)
            
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = "File not found:\n\(path)"
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
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
    
    func deleteNoteById(_ noteId: Int64) {
        if Utils.showYesNoDialog("Delete note", "Are you sure you want to delete this note?") {
            db.deleteNote(noteId)
        }
    }
    
    func saveNote(_ data: String, _ tags: String) {
        // TODO: check DB connection
        
        let tagsArray = tags.components(separatedBy: ",").filter {!$0.isEmpty}
        print(tags)
        
        guard !data.isEmpty else {return}
        guard !tagsArray.isEmpty else {
            Utils.showWarning("Tag required", "Please add at least 1 tag\ne.g. \"Work\" or \"TODO\"")
            return
        }
        
        // TODO: insert vs edit
        let newNoteId = db.insertNote(data)
        db.linkTagsToNote(newNoteId, tagsArray)
        Utils.showInfo("Done", "Note added")
    }
    
    private func addToRecentFilesList(_ item: String) {
        UserDefaults.standard.set([item] + getRecentFiles().filter {$0 != item}, forKey: recentFilesKey)
    }
    
    private func removeFromRecentFilesList(_ item: String) {
        UserDefaults.standard.set(getRecentFiles().filter {$0 != item}, forKey: recentFilesKey)
    }
    
    func _debug() {
        UserDefaults.standard.removeObject(forKey: recentFilesKey)
    }
}
