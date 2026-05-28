import SwiftUI

struct ToggleField: View {
    let field: FormField
    @ObservedObject var viewModel: DynamicFormViewModel

    var body: some View {
        let colors = viewModel.colors
        let binding = Binding<Bool>(
            get: { viewModel.boolValues[field.id] ?? false },
            set: { viewModel.updateBool($0, for: field.id) }
        )

        Toggle(isOn: binding) {
            Text(field.label)
                .foregroundColor(Color(hex: colors.textHex, fallback: .primary))
                .fixedSize(horizontal: false, vertical: true)
        }
        .tint(Color(.systemCyan))
    }
}
