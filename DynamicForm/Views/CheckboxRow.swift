import SwiftUI

struct CheckboxRow: View {
    let title: String
    let isSelected: Bool
    let colors: FormColors
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? Color(.systemCyan) : Color(hex: colors.borderHex, fallback: .accentColor))
                    .padding(.top, 2)

                Text(title)
                    .foregroundColor(Color(hex: colors.textHex, fallback: .primary))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
}
