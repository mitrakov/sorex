import SQLite

class SQLiteDatabase {
    private var db: Connection?
    
    /// Establishes a new connection to database. Closes the old database connection, if required
    /// - Parameters:
    ///   - path: The location of the database
    func openDb(_ path: String) {
        closeDb()
        do {
            db = try Connection(path)
        } catch {print(error)}
        db?.foreignKeys = true // PRAGMA foreign_keys=ON; (in SQLite it's disabled by default)
    }
    
    /// Closes the database. If no databases open, does nothing
    func closeDb() {
        db = nil // internal DB connection will be closed by deinit()
    }
    
    /// Checks if a DB is open
    /// - Returns: true if DB is connected
    func isConnected() -> Bool {
        return db != nil
    }
    
    /// Creates a new database
    /// - Parameters:
    ///   - path: The location of the database
    func createDb(_ path: String) {
        openDb(path)
        do {
            try db?.transaction {
                try db?.execute("""
                    CREATE TABLE note (
                      note_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                      author VARCHAR(64) NOT NULL DEFAULT '',
                      client VARCHAR(255) NOT NULL DEFAULT '',
                      user_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                      colour INTEGER NOT NULL DEFAULT 16777215,
                      rank TINYINT NOT NULL DEFAULT 0,
                      is_visible BOOLEAN NOT NULL DEFAULT true,
                      is_favourite BOOLEAN NOT NULL DEFAULT false,
                      is_deleted BOOLEAN NOT NULL DEFAULT false,
                      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                      updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                    );
                    CREATE VIRTUAL TABLE notedata USING FTS5(data);
                    CREATE TABLE tag (
                      tag_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                      name VARCHAR(64) UNIQUE NOT NULL,
                      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                      updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                    );
                    CREATE TABLE image (
                      guid UUID PRIMARY KEY NOT NULL,
                      data BLOB NOT NULL,
                      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                      updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                    );
                    CREATE TABLE note_to_tag (
                      note_id INTEGER NOT NULL REFERENCES note (note_id) ON UPDATE RESTRICT ON DELETE CASCADE,
                      tag_id  INTEGER NOT NULL REFERENCES tag (tag_id) ON UPDATE RESTRICT ON DELETE CASCADE,
                      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                      updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                      PRIMARY KEY (note_id, tag_id)
                    );
                    """)
                db?.userVersion = 3
            }
        } catch {print(error)}
    }
    
    /// Adds a new note to the database
    /// - Parameters:
    ///   - data: markdown string
    /// - Returns: A new generated note ID
    func insertNote(_ data: String) -> Int64 {
        var noteId: Int64 = 0
        do {
            try db?.transaction {
                try db?.execute("INSERT INTO note DEFAULT VALUES;") // INSERT doesn't provide last insert ID
                noteId = db?.lastInsertRowid ?? -1
                try db?.run("INSERT INTO notedata (rowid, data) VALUES (?, ?);", noteId, data)
            }
        } catch {print(error)}
        return noteId
    }
    
    /// Updates the given note in the database
    /// - Parameters:
    ///   - noteId: note ID
    ///   - data: markdown string
    func updateNote(_ noteId: Int64, _ data: String) {
        do {
            try db?.run("UPDATE notedata SET data = ? WHERE rowid = ?;", data, noteId)
        } catch {print(error)}
    }
    
    /// Removes a given note from the database
    /// - Parameters:
    ///   - noteId: note ID
    func deleteNote(_ noteId: Int64) {
        do {
            try db?.transaction {
                try db?.run("DELETE FROM note     WHERE note_id = ?;", noteId); // TODO soft delete?
                try db?.run("DELETE FROM notedata WHERE rowid = ?;", noteId);
                try db?.run("DELETE FROM tag      WHERE tag_id NOT IN (SELECT DISTINCT tag_id FROM note_to_tag);");
            }
        } catch {print(error)}
    }
    
    /// Fetches all notes from the database
    /// - Returns: a list on notes
    func getNotes() -> [Note] {
        let sql = """
          SELECT note_id, data, GROUP_CONCAT(name, ', ') AS tags
          FROM note
          INNER JOIN notedata ON note_id = notedata.rowid
          INNER JOIN note_to_tag USING (note_id)
          INNER JOIN tag         USING (tag_id)
          GROUP BY note_id
          ORDER BY note_id ASC
          ;
        """
        do {
            return try db?.run(sql).map {Note(id: $0[0] as! Int64, data: $0[1] as! String, tags: $0[2] as! String)} ?? []
        } catch {print(error)}
        
        return []
    }
    
    /// Fetches all tags from the database
    /// - Returns: a list of tags
    func getTags() -> [String] {
        do {
            return try db?.run("SELECT name FROM tag ORDER BY name;").map {$0[0] as! String} ?? []
        } catch {print(error)}
        return []
    }
    
    /// Searches for a single note by ID
    /// - Parameters:
    ///   - id: note ID
    /// - Returns: optional Note
    func searchByID(_ id: Int64) -> Note? {
        let sql = """
          SELECT note_id, data, GROUP_CONCAT(name, ', ') AS tags
          FROM note
          INNER JOIN notedata ON note_id = notedata.rowid
          INNER JOIN note_to_tag USING (note_id)
          INNER JOIN tag         USING (tag_id)
          WHERE note_id = ?
          GROUP BY note_id
          ;
        """
        do {
            return try db?.run(sql, id).map {Note(id: $0[0] as! Int64, data: $0[1] as! String, tags: $0[2] as! String)}.first
        } catch {print(error)}

        return nil
    }

    /// Searches for multiple notes by a given tag
    /// - Parameters:
    ///   - tag: tag to search
    /// - Returns: a list of notes
    func searchByTag(_ tag: String) -> [Note] {
        let sql = """
          SELECT note_id, data, GROUP_CONCAT(name, ', ') AS tags
          FROM note
          INNER JOIN notedata ON note_id = notedata.rowid
          INNER JOIN note_to_tag USING (note_id)
          INNER JOIN tag         USING (tag_id)
          WHERE note_id IN (SELECT note_id FROM tag INNER JOIN note_to_tag USING (tag_id) WHERE name = ?)
          GROUP BY note_id
          ORDER BY note.updated_at DESC
          ;
        """
        do {
            return try db?.run(sql, tag).map {Note(id: $0[0] as! Int64, data: $0[1] as! String, tags: $0[2] as! String)} ?? []
        } catch {print(error)}
        
        return []
    }
    
    /// Searches for multiple notes by a given keyword (full text search)
    /// - Parameters:
    ///   - tag: keyword to search
    /// - Returns: a list of notes
    func searchByKeyword(_ word: String) -> [Note] {
        guard !word.isEmpty else {return []}

        let sql = """
          SELECT note_id, data, GROUP_CONCAT(name, ', ') AS tags
          FROM note
          INNER JOIN notedata ON note_id = notedata.rowid
          INNER JOIN note_to_tag USING (note_id)
          INNER JOIN tag         USING (tag_id)
          WHERE data MATCH ?
          GROUP BY note_id
          ORDER BY notedata.rank ASC, note.updated_at DESC
          ;
        """
        do {
            return try db?.run(sql, word).map {Note(id: $0[0] as! Int64, data: $0[1] as! String, tags: $0[2] as! String)} ?? []
        } catch {print(error)}
        
        return []
    }
    
    /// Attaches given tags to a given note
    /// - Parameters:
    ///   - noteId: note ID
    ///   - tags: list of tags to attach to the note (empty array does nothing)
    func linkTagsToNote(_ noteId: Int64, _ tags: [String]) {
        guard !tags.isEmpty else {return}
        
        do {
            try db?.transaction {
                try tags.forEach { tag in
                    let tagIdOpt = try db?.scalar("SELECT tag_id FROM tag WHERE name = ?;", tag) as? Int64;
                    let tagId = tagIdOpt ?? {
                        do {
                            try db?.run("INSERT INTO tag (name) VALUES (?);", tag); // INSERT doesn't provide last insert ID
                        } catch {print(error)}
                        
                        return db?.lastInsertRowid ?? -1
                    }();

                    try db?.run("INSERT INTO note_to_tag (note_id, tag_id) VALUES (?, ?);", noteId, tagId);
                }
            }
        } catch {print(error)}
    }

    /// Detaches given tags from a given note
    /// - Parameters:
    ///   - noteId: note ID
    ///   - tags: list of tags to detach from the note (empty array does nothing)
    func unlinkTagsFromNote(_ noteId: Int64, _ tags: [String]) {
        guard !tags.isEmpty else {return}
        
        let IN = [String](repeating: "?", count: tags.count).joined(separator: ",") // "?,?,?,?"
        do {
            try db?.transaction {
                try db?.run("DELETE FROM note_to_tag WHERE note_id = ? AND tag_id IN (SELECT tag_id FROM tag WHERE name IN (\(IN)));", [noteId] + tags); // TODO soft delete?
                try db?.run("DELETE FROM tag WHERE tag_id NOT IN (SELECT DISTINCT tag_id FROM note_to_tag);");
            }
        } catch {print(error)}
    }
}
