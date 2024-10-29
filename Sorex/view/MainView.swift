import SwiftUI
import MarkdownView

// edit: emojii support
// bug with overwriting same file
struct MainView: View {
    @ObservedObject var vm: MainViewModel
    @State private var currentText = ""              // main text in add/edit mode (insert/update note)
    @State private var currentTags = ""              // comma-separated tags in the text field (insert/update note)
    @State private var currentNoteId: Int64?         // if present, it's an ID of the note in edit mode
    @State private var notes: [Note] = []            // in view mode, DB notes array for markdown view
    @State private var currentTag = ""               // after note deletion we should update view w/o the removed note
    @State private var editorMode = EditorMode.edit  // edit or view mode
    @State private var oldTags = ""                  // old comma-separated tags for edit mode (to calc tags diff)
    
    var body: some View {
        NavigationSplitView {
            VStack {
                HStack {
                    Button {
                        setEditMode()
                    } label: {
                        VStack {
                            Image(systemName: "plus.app")
                                .padding(4)
                                .font(.system(size: 26, weight: .bold))
                                .background(Color.white)
                                .cornerRadius(10)
                                .frame(width: 30, height: 30)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 5, y: 5)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: -5, y: 5)
                            
                            Text("New")
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.leading, 8)
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                ScrollView {
                    ForEach(vm.getTags(), id: \.self) { tag in
                        HStack {
                            Button {
                                setReadMode(notes: vm.searchByTag(tag), tag: tag)
                            } label: {
                                Text(tag)
                                Spacer()
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        } detail: {
            VStack {
                switch editorMode {
                case .read:
                    ScrollView {
                        ForEach(notes) { note in
                            ZStack(alignment: .topTrailing) {
                                MarkdownView(text: note.data)
                                    .textSelection(.enabled)
                                ContextMenu(tags: Utils.splitStringBy(note.tags, ","),
                                  onEdit: {
                                    setEditMode(noteId: note.id, text: note.data, tags: note.tags)
                                }, onDelete: {
                                    vm.deleteNoteById(note.id)
                                    setReadMode(notes: vm.searchByTag(currentTag), tag: currentTag)
                                })
                            }
                            Divider()
                        }
                    }
                    .padding(4)
                case .edit:
                    HSplitView {
                        TextEditor(text: $currentText)
                            .font(.custom("HelveticaNeue", size: 14))
                            .foregroundColor(.black)
                            .padding(4)

                        ScrollView {
                            MarkdownView(text: currentText)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .padding(4)
                    }
                    Spacer()
                    HStack {
                        TextField("Tags...", text: $currentTags) // TODO: bug
                            .frame(maxWidth: 200)
                            .cornerRadius(16)
                        
                        Button {
                            let newId = vm.saveNote(currentNoteId, data: currentText, newTags: currentTags, oldTags: oldTags)
                            if let newId = newId, let note = vm.searchByID(newId) {
                                setReadMode(notes: [note])
                            }
                        } label: {
                            Label {
                                Text(currentNoteId == nil ? "Add Note" : "Update Note")
                            } icon: {
                                Image(systemName: currentNoteId == nil ? "plus.circle" : "checkmark.seal")
                            }
                            .foregroundColor(.black.opacity(0.8))
                        }
                        
                        Spacer()
                    }.padding(.bottom, 10)
                }
            }
        }
        .preferredColorScheme(.light)
    }
    
    private func setEditMode(noteId: Int64? = nil, text: String = "", tags: String = "") {
        self.currentText = text
        self.currentTags = tags
        self.currentNoteId = noteId
        self.notes = []
        self.currentTag = ""
        self.editorMode = .edit
        self.oldTags = tags
    }
    
    private func setReadMode(notes: [Note], tag: String = "") {
        self.currentText = ""
        self.currentTags = ""
        self.currentNoteId = nil
        self.notes = notes
        self.currentTag = tag
        self.editorMode = .read
        self.oldTags = ""
    }
}

enum EditorMode {
    case read, edit
}

#Preview {
    MainView(vm: MainViewModel())
}
