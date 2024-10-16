import SwiftUI
import MarkdownView

struct ContentView: View {
    @State var currentText = ""
    @State var currentTags = ""
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
                switch editorMode {
                case .read:
                    ScrollView {
                        ForEach(markdown, id: \.self) { md in
                            MarkdownView(text: md)
                                .textSelection(.enabled)
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
                        
                        Button(action: {}, label: {
                            Label(title: {
                                Text("Add Note")
                            }, icon: {
                                Image(systemName: "plus.bubble.fill")
                            })
                            .foregroundColor(.black.opacity(0.8))
                        })
                        
                        Spacer()
                    }.padding(.bottom, 10)
                }
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

