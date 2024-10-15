import SwiftUI
import MarkdownView

struct ContentView: View {
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
            ScrollView {
                ForEach(markdown, id: \.self) { md in
                    MarkdownView(text: md)
                    Divider()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

