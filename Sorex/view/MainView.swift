import SwiftUI
import MarkdownView

struct MainView: View {
    @ObservedObject var vm: MainViewModel
    @State private var currentText = ""              // binding for main text in add/edit mode
    @State private var currentTags = ""              // binding for comma-separated tags in the text field
    @State private var searchKeyword = ""            // binding for full-text search textfield
    @State private var currentNoteId: Int64?         // if present, it's an ID of the note in edit mode
    @State private var oldTags = ""                  // old comma-separated tags for edit mode (to calc tags diff)
    @State private var notes: [Note] = []            // in view mode, DB notes array for markdown view
    @State private var search = ""                   // name of tag (SearchMode.tag) or keyword (SearchMode.keyword)
    @State private var editorMode = EditorMode.edit  // edit or view mode
    @State private var searchMode = SearchMode.tag   // how to search notes (by clicking tag, by full-text, etc)    
    
    var body: some View {
        HSplitView { // don't use NavigationSplitView because of the bug in SwiftUI (https://stackoverflow.com/q/74585499)
            VStack {
                HStack(alignment: .top) {
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
                    
                    TextField("Global search...", text: $searchKeyword)
                        .cornerRadius(16)
                        .padding(4)
                        .onSubmit {
                            setReadMode(search: searchKeyword, by: .keyword)
                        }
                }
                ScrollView {
                    ForEach(vm.getTags(), id: \.self) { tag in
                        HStack {
                            Button {
                                setReadMode(search: tag, by: .tag)
                            } label: {
                                Text(tag)
                                Spacer()
                            }
                            
                            Spacer()
                        }
                    }
                }
            }.frame(maxWidth: 200)

            HStack {
                Spacer()
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
                                        setReadMode(search: search, by: searchMode)
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
                                if let newId = newId {
                                    setReadMode(search: String(newId), by: .id)
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
        }
        .preferredColorScheme(.light)
    }
    
    private func setEditMode(noteId: Int64? = nil, text: String = "", tags: String = "") {
        self.currentText = text
        self.currentTags = tags
        self.searchKeyword = ""
        self.currentNoteId = noteId
        self.oldTags = tags
        self.notes = []
        self.search = ""
        self.editorMode = .edit
        self.searchMode = .tag
    }
    
    private func setReadMode(search: String, by: SearchMode) {
        self.currentText = ""
        self.currentTags = ""
        self.searchKeyword = searchKeyword
        self.currentNoteId = nil
        self.oldTags = ""
        self.notes = by == .tag     ? vm.searchByTag(search) :
                     by == .keyword ? vm.searchByKeyword(search) :
                     by == .id      ? vm.searchByID(Int64(search)!).map{[$0]} ?? [] : []
        self.search = search
        self.editorMode = .read
        self.searchMode = by
    }
}

enum EditorMode {
    case read, edit
}

enum SearchMode {
    case tag, keyword, id
}

#Preview {
    MainView(vm: MainViewModel())
}
