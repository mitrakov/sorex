import SwiftUI
import MarkdownView

// edit: emojii support
// bug with overwriting same file
struct MainView: View {
    @ObservedObject var vm: MainViewModel
    @State private var currentText = ""              // main text in add/edit mode
    @State private var currentTags = ""              // comma-separated tags in the text field at the bottom
    @State private var currentTag = ""               // last searched tag
    @State private var notes: [Note] = []            // DB notes array for markdown view
    @State private var editorMode = EditorMode.edit  // edit or view
    
    var body: some View {
        NavigationSplitView {
            VStack {
                HStack {
                    Button {
                        editorMode = .edit
                        notes = []
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
                                editorMode = .read
                                notes = vm.searchByTag(tag)
                                currentTag = tag
                            } label: {
                                Text(tag)
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
                                ContextMenu(tags: note.tags.components(separatedBy: ","), onEdit: {}, onDelete: {
                                    vm.deleteNoteById(note.id)
                                    notes = vm.searchByTag(currentTag) // update view
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
                        TextField("Tags...", text: $currentTags)
                            .frame(maxWidth: 200)
                            .cornerRadius(16)
                        
                        Button {
                            vm.saveNote(currentText, currentTags)
                            // TODO: update state
                        } label: {
                            Label {
                                Text("Add Note")
                            } icon: {
                                Image(systemName: "plus.bubble.fill")
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
}

enum EditorMode {
    case read, edit
}

#Preview {
    MainView(vm: MainViewModel())
}
