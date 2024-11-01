import SwiftUI
import MarkdownUI // don't use "https://github.com/LiYanan2004/MarkdownView", it has performance issues

struct MainView: View {
    @EnvironmentObject var vm: MainViewModel
    @State private var currentText = ""              // binding for main text in add/edit mode
    @State private var currentTags = ""              // binding for comma-separated tags in the text field
    @State private var searchKeyword = ""            // binding for full-text search textfield
    @State private var currentNoteId: Int64?         // if present, it's an ID of the note in edit mode
    @State private var oldTags = ""                  // old comma-separated tags for edit mode (to calc tags diff)
    @State private var notes: [Note] = []            // in view mode, DB notes array for markdown view
    @State private var search = ""                   // search by tag name (SearchMode.tag), keyword (.keyword) or ID (.id)
    @State private var editorMode = EditorMode.edit  // edit or view mode
    @State private var searchMode = SearchMode.tag   // how to search notes (by clicking tag, by full-text, etc)
    
    var body: some View {
        HSplitView {
            // LEFT TOOLBAR
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
                    .padding(8)
                    .disabled(vm.currentPath == nil)
                    .buttonStyle(PlainButtonStyle())
                    
                    // don't use TextField due to bug: https://stackoverflow.com/q/74585499
                    FocusableTextField(stringValue: $searchKeyword, placeholder: "Global search...", onEnter: {
                        setReadMode(search: searchKeyword, by: .keyword)
                    })
                    .cornerRadius(12)
                    .padding(.top, 16)
                    .padding(.trailing, 8)
                }
                // LIST OF TAGS
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
            }
            .padding(.leading, 8)
            .frame(maxWidth: 200)

            // RIGHT MAIN AREA
            HStack {
                Spacer()
                VStack {
                    switch editorMode {
                    case .read:
                        ScrollView {
                            if vm.currentPath != nil {
                                // LIST OF NOTES
                                ForEach(notes) { note in
                                    ZStack(alignment: .topTrailing) {
                                        HStack {
                                            Markdown(note.data)
                                                .markdownTheme(.docC)
                                                .textSelection(.enabled)
                                            Spacer()
                                        }
                                        
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
                            } else {
                                EmptyView()
                            }
                        }
                        .padding(4)
                    case .edit:
                        HSplitView {
                            // LEFT EDITOR
                            TextEditor(text: $currentText)
                                .font(.system(size: 14, weight: .regular, design: .monospaced))
                                .foregroundColor(.black)
                                .padding(4)

                            // RIGHT PREVIEW
                            ScrollView {
                                HStack {
                                    Markdown(currentText)
                                        .markdownTheme(.docC)
                                        .textSelection(.enabled)
                                    Spacer()
                                }
                            }
                            .padding(4)
                        }
                        Spacer()
                        // BOTTOM PANEL
                        HStack {
                            Text("Tags:")
                            // don't use TextField due to bug: https://stackoverflow.com/q/74585499
                            FocusableTextField(stringValue: $currentTags, placeholder: "Tags...", onEnter: {
                                saveNote()
                            })
                            .frame(maxWidth: 200)
                            .cornerRadius(8)
                            
                            Button {
                                saveNote()
                            } label: {
                                Label {
                                    Text(currentNoteId == nil ? "Add Note" : "Update Note")
                                        .font(.system(size: 13, weight: .semibold))
                                } icon: {
                                    Image(systemName: currentNoteId == nil ? "plus.circle" : "checkmark.seal")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .foregroundColor(.black.opacity(0.8))
                            }
                            .disabled(vm.currentPath == nil)
                            
                            Spacer()
                        }.padding(.bottom, 10)
                    }
                }
            }
        }
        .preferredColorScheme(.light)
        .navigationTitle(vm.currentPath ?? "Sorex")
    }
    
    private func saveNote() {
        if let newId = vm.saveNote(currentNoteId, data: currentText, newTags: currentTags, oldTags: oldTags) {
            setReadMode(search: String(newId), by: .id)
        }
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
    MainView().environmentObject(MainViewModel())
}
