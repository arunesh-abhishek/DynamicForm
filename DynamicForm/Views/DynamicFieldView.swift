import SwiftUI

struct DynamicFieldView: View {
    let field: FormField
    @ObservedObject var viewModel: DynamicFormViewModel
    var isTextInputFocused: FocusState<Bool>.Binding

    var body: some View {
        let colors = viewModel.colors

        VStack(alignment: .leading, spacing: 8) {
            switch field.type {
            case FieldType.text:
                TextInputField(
                    field: field,
                    viewModel: viewModel,
                    isTextInputFocused: isTextInputFocused
                )
            case FieldType.dropdown:
                FieldHeaderView(field: field, viewModel: viewModel)
                DropdownField(field: field, viewModel: viewModel)
            case FieldType.toggle:
                ToggleField(field: field, viewModel: viewModel)
            case FieldType.checkbox:
                CheckboxField(field: field, viewModel: viewModel)
            default:
                EmptyView()
            }

            if let error = viewModel.errors[field.id] {
                Text(error)
                    .font(.caption)
                    .foregroundColor(Color(hex: colors.errorHex, fallback: .red))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
