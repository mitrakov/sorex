import SQLite

struct Note: Identifiable {
    let id: Int
    let data: String
    let tags: String
}

class SQLiteDatabase {
    private var db: Connection?
    
    func openDb(_ path: String) {
        do {
            db = try Connection(path) // old DB connection will be closed by deinit()
            db?.foreignKeys = true
        } catch {print(error)}
    }
    
    func getTags() -> [String] {
        let sql = "SELECT name FROM tag ORDER BY name;"
        do {
            return try db?.prepare(sql).map {$0[0] as! String} ?? []
        } catch {
            print(error)
            return []
        }
    }
    
    func getNotes() -> [Note] {
        let sql = """
          SELECT note_id, data, GROUP_CONCAT(name, ', ') AS tags
          FROM note
          INNER JOIN notedata ON note_id = notedata.rowid
          INNER JOIN note_to_tag USING (note_id)
          INNER JOIN tag         USING (tag_id)
          GROUP BY note_id;
        """
        do {
            return try db?.prepare(sql).map {Note(id: Int($0[0] as! Int64), data: $0[1] as! String, tags: $0[2] as! String)} ?? []
        } catch {
            print(error)
            return []
        }
    }
    
    func searchByTag(_ tag: String) -> [Note] {
        let sql = """
          SELECT note_id, data
          FROM notedata
          INNER JOIN note_to_tag ON notedata.rowid = note_id
          INNER JOIN tag USING (tag_id)
          WHERE name = ?
          ORDER BY note_to_tag.updated_at DESC;
        """
        do {
            return try db?.prepare(sql).run(tag).map {Note(id: Int($0[0] as! Int64), data: $0[1] as! String, tags: tag)} ?? []
        } catch {
            print(error)
            return []
        }
    }
    
    func hey() {
        //db.
    }
}
