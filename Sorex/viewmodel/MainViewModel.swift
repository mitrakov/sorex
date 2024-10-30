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
        guard db.isConnected() else {return []}
        return db.getTags()
    }
    
    func getNotes() -> [Note] {
        guard db.isConnected() else {return []}
        return db.getNotes()
    }
    
    func searchByID(_ noteId: Int64) -> Note? {
        guard db.isConnected() else {return nil}
        return db.searchByID(noteId)
    }
    
    func searchByTag(_ tag: String) -> [Note] {
        guard !tag.isEmpty else {return []}
        guard db.isConnected() else {return []}
        return db.searchByTag(tag)
    }
    
    func searchByKeyword(_ word: String) -> [Note] {
        guard !word.isEmpty else {return []}
        guard db.isConnected() else {return []}
        return db.searchByKeyword(word)
    }
    
    func deleteNoteById(_ noteId: Int64) {
        guard db.isConnected() else {return}
        if Utils.showYesNoDialog("Delete note", "Are you sure you want to delete this note?") {
            db.deleteNote(noteId)
        }
    }
    
    func saveNote(_ noteId: Int64?, data: String, newTags: String, oldTags: String) -> Int64? {
        let tags = Utils.splitStringBy(newTags, ",")
        guard db.isConnected() else {return nil}
        guard !data.isEmpty else {return nil}
        guard !tags.isEmpty else {
            Utils.showWarning("Tag required", "Please add at least 1 tag\ne.g. \"Work\" or \"TODO\"")
            return nil
        }
        
        if let noteId = noteId {
            // UPDATE
            db.updateNote(noteId, data)
            updateTags(noteId, newTags: newTags, oldTags: oldTags)
            Utils.showInfo("Done", "Note updated")
            return noteId
        } else {
            // INSERT
            let newNoteId = db.insertNote(data)
            db.linkTagsToNote(newNoteId, tags)
            Utils.showInfo("Done", "Note added")
            return newNoteId
        }
    }
    
    private func updateTags(_ noteId: Int64, newTags: String, oldTags: String) {
        let oldTags = Set(Utils.splitStringBy(oldTags, ","))
        let newTags = Set(Utils.splitStringBy(newTags, ","))
        let rmTags  = Array(oldTags.subtracting(newTags))
        let addTags = Array(newTags.subtracting(oldTags))
        
        db.unlinkTagsFromNote(noteId, rmTags)
        db.linkTagsToNote(noteId, addTags)
    }
    
    private func addToRecentFilesList(_ item: String) {
        UserDefaults.standard.set([item] + getRecentFiles().filter {$0 != item}, forKey: recentFilesKey)
    }
    
    private func removeFromRecentFilesList(_ item: String) {
        UserDefaults.standard.set(getRecentFiles().filter {$0 != item}, forKey: recentFilesKey)
    }
}
