import SwiftUI

struct ContextMenu: View {
    let tags: [String]
    let onEdit: () -> Void
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
            }
            
            Button(action: onEdit, label: {
                Image(systemName: "pencil.circle")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .padding(4)
                    .background(Color.blue.opacity(0.5))
                    .clipShape(Circle())
            })
            .buttonStyle(PlainButtonStyle())
            
            Button (action: onDelete, label: {
                Image(systemName: "trash.slash")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color.red.opacity(0.8))
                    .clipShape(Circle())
            })
            .buttonStyle(PlainButtonStyle())
            .padding(.trailing, 4)
        }
    }
}

#Preview {
    ContextMenu(tags: ["One", "Two", "Three"], onEdit: {}, onDelete: {})
}
