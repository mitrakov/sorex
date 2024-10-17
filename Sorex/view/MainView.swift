import SwiftUI
import MarkdownView

struct MainView: View {
    @ObservedObject var vm: MainViewModel
    @State var currentText = ""
    @State var currentTags = ""
    @State var markdown = [""]
    @State var editorMode = EditorMode.edit
    
    var body: some View {
        NavigationSplitView {
            VStack {
                HStack {
                    Button {
                        editorMode = .edit
                        markdown = [currentText]
                    } label: {
                        Image(systemName: "folder.fill.badge.plus")
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(10)
                            .frame(width: 30, height: 30)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 5, y: 5)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: -5, y: 5)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                ScrollView {
                    ForEach(vm.getTags(), id: \.self) { tag in
                        HStack {
                            Button {
                                editorMode = .read
                                markdown = vm.searchByTag(tag).map {$0.data}
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
                        
                        Button{
                            // not impl
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
    }
}

enum EditorMode {
    case read, edit
}

#Preview {
    MainView(vm: MainViewModel())
}
