import SwiftUI
import MarkdownView

struct ContentView: View {
    @State var currentText = ""
    @State var markdown = [""]
    let db = SQLiteDatabase()
    
    var body: some View {
        NavigationSplitView {
            ScrollView {
                ForEach(db.getTags(), id: \.self) { tag in
                    HStack {
                        Button(action: {
                            markdown = db.searchByTag(tag: tag).map {$0.data}
                        }, label: {
                            Text(tag)
                        })
                        
                        Spacer()
                    }
                }
            }
        } detail: {
            VStack {
                HSplitView {
                    TextEditor(text: $currentText)
                        .foregroundColor(.black)
                        .textFieldStyle(.roundedBorder)
                        .padding(4)

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

#Preview {
    ContentView()
}

