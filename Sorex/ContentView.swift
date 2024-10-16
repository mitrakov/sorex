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
                    ScrollView {
                        TextField("Input your note here...", text: $currentText, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(10)
                            .padding()
                    }
                    ScrollView {
                        ForEach(markdown, id: \.self) { md in
                            MarkdownView(text: md)
                            Divider()
                        }
                    }
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

