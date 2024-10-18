import Foundation

class MainViewModel: ObservableObject {
    let db = SQLiteDatabase()
    @Published var currentPath: String?
    
    func openFile(_ path: String) {
        db.openDb(path)
        currentPath = path
    }
    
    func openFile() {
        let path = "fesfse" // TODO file picker
        db.openDb(path)
        currentPath = path
    }
    
    func newFile() {
        let path = "fesfse" // TODO file picker
        db.createDb(path)
        currentPath = path
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
