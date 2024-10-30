import Foundation

class MainViewModel: ObservableObject {
    private let db = SQLiteDatabase()
    private let files = FileManager.default
    @Published var currentPath: String?
    
    func openFile(_ path: String) {
        if files.fileExists(atPath: path) {
            print("Opening file \(path)")
            db.openDb(path)
            currentPath = path
            addToRecentFilesList(path)
        } else {
            Utils.showAlert("Error", "File not found:\n\(path)", .critical)
            removeFromRecentFilesList(path)
        }
    }
    
    func openFile() {
        if let path = Utils.showOpenFileDialog("Select a DB file", ["db"]) {
            self.openFile(path)
        }
    }
    
    func newFile() {
        if let path = Utils.showSaveFileDialog(title: "New DB file", message: "Create a new DB file", nameLabel: "DB name", defaultName: "mydb", ["db"]) {
            if files.fileExists(atPath: path) {
                if Utils.showYesNoDialog("Warning", "File already exists:\n\(path)\n\nDo you want to erase it?\nIt will remove all data") {
                    db.closeDb()
                    do {
                        try files.removeItem(atPath: path)
                    } catch {print(error)}
                } else {return}
            }
            
            print("Creating file \(path)")
            db.createDb(path)
            currentPath = path
            addToRecentFilesList(path)
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
            Utils.showAlert("Tag required", "Please add at least 1 tag\ne.g. \"Work\" or \"TODO\"", .warning)
            return nil
        }
        
        if let noteId = noteId {
            // UPDATE
            db.updateNote(noteId, data)
            updateTags(noteId, newTags: newTags, oldTags: oldTags)
            Utils.showAlert("Done", "Note updated")
            return noteId
        } else {
            // INSERT
            let newNoteId = db.insertNote(data)
            db.linkTagsToNote(newNoteId, tags)
            Utils.showAlert("Done", "Note added")
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
