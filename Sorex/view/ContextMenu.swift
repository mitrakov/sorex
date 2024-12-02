import SwiftUI

struct ContextMenu: View {
    let isArchived: Bool
    let tags: [String]
    let onEdit: () -> Void
    let onArchive: () -> Void
    let onRestore: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            ForEach(tags, id: \.self) {
                Label($0, systemImage: "tag")
                    .padding(4)
                    .border(Color.blue)
                    .cornerRadius(16)
                    .background(Capsule().strokeBorder(Color.purple))
                    .opacity(isArchived ? 0.6 : 1)
            }
            
            if (isArchived) {
                Button(action: onRestore, label: {
                    Image(systemName: "arrow.uturn.backward.circle")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .padding(4)
                        .background(Color.green.opacity(0.5))
                        .clipShape(Circle())
                })
                .buttonStyle(PlainButtonStyle())
                .help("Restore from archive")
                .padding(.trailing, 16)
            } else {
                Button(action: onEdit, label: {
                    Image(systemName: "pencil.circle")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .padding(4)
                        .background(Color.blue.opacity(0.5))
                        .clipShape(Circle())
                })
                .buttonStyle(PlainButtonStyle())
                .help("Edit note")

                Button(action: onArchive, label: {
                    Image(systemName: "archivebox.circle")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .padding(4)
                        .background(Color.orange.opacity(0.5))
                        .clipShape(Circle())
                })
                .buttonStyle(PlainButtonStyle())
                .help("Archive note")
                
                Button (action: onDelete, label: {
                    Image(systemName: "trash.slash")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .padding(8)
                        .background(Color.red.opacity(0.8))
                        .clipShape(Circle())
                })
                .buttonStyle(PlainButtonStyle())
                .help("Delete note")
                .padding(.trailing, 16)
            }
        }
    }
}

#Preview {
    ContextMenu(isArchived: false, tags: ["One", "Two", "Three"], onEdit: {}, onArchive: {}, onRestore: {}, onDelete: {})
}
