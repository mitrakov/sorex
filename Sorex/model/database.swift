//import Foundation
import SQLite

struct Note: Identifiable {
    let id: Int
    let data: String
    let tags: String
}

class SQLiteDatabase {
    let db = try! Connection("/Users/tommy/Yandex.Disk.localized/all/db/it.db") // TODO try!
    
    func getTags() -> [String] {
        let sql = "SELECT name FROM tag ORDER BY name;"
        do {
            return try db.prepare(sql).map({row in "\(row[0] ?? "")"})
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
            return try db.prepare(sql).map({row in Note(id: Int("\(row[0] ?? "")") ?? 0, data: "\(row[1] ?? "")", tags: "\(row[2] ?? "")")})
        } catch {
            print(error)
            return []
        }
    }
    
    func searchByTag(tag: String) -> [Note] {
        let sql = """
          SELECT note_id, data
          FROM notedata
          INNER JOIN note_to_tag ON notedata.rowid = note_id
          INNER JOIN tag USING (tag_id)
          WHERE name = ?
          ORDER BY note_to_tag.updated_at DESC;
        """
        
        do {
            return try db.prepare(sql).run(tag).map({row in Note(id: Int("\(row[0] ?? "")") ?? 0, data: "\(row[1] ?? "")", tags: tag)})
        } catch {
            print(error)
            return []
        }
    }
}
