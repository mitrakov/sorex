import SwiftUI
import MarkdownUI

struct ContentView: View {
    @State var markdown = [""]
    let db = SQLiteDatabase()
    
    var body: some View {
        NavigationSplitView {
            ScrollView {
                ForEach(db.getTags(), id: \.self) { tag in
                    HStack {
                        Button(action: {
                            markdown = db.searchByTag(tag: tag).map({x in x.data})
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
                    Markdown(md).markdownTheme(.gitHub)
                    Divider()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
