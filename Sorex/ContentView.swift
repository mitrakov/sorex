import SwiftUI
import MarkdownView

struct ContentView: View {
    @State var currentText = ""
    @State var markdown = [""]
    @State var editorMode = EditorMode.edit
    
    let db = SQLiteDatabase()
    
    var body: some View {
        NavigationSplitView {
            VStack {
                HStack {
                    Button(action: {
                        editorMode = .edit
                        markdown = [currentText]
                    }, label: {
                        Image(systemName: "folder.fill.badge.plus")
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(10)
                            .frame(width: 30, height: 30)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 5, y: 5)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: -5, y: 5)
                    }).buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                ScrollView {
                    ForEach(db.getTags(), id: \.self) { tag in
                        HStack {
                            Button(action: {
                                editorMode = .read
                                markdown = db.searchByTag(tag: tag).map {$0.data}
                            }, label: {
                                Text(tag)
                            })
                            
                            Spacer()
                        }
                    }
                }
            }
        } detail: {
            VStack {
                HSplitView {
                    if editorMode == .edit {
                        TextEditor(text: $currentText)
                            .foregroundColor(.black)
                            .textFieldStyle(.roundedBorder)
                            .padding(4)
                    }

                    ScrollView {
                        ForEach(markdown, id: \.self) { md in
                            MarkdownView(text: md)
                                .textSelection(.enabled)
                            Divider()
                        }
                    }
                    .padding(4)
                }
                Spacer()
                Text("Hey Hey")
            }
        }
    }
}

enum EditorMode {
    case read, edit
}

#Preview {
    ContentView()
}

