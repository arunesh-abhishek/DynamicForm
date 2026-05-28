import SwiftUI

struct TextInputField: View {
    let field: FormField
    @ObservedObject var viewModel: DynamicFormViewModel
    var isTextInputFocused: FocusState<Bool>.Binding
    @State private var secureText = ""

    var body: some View {
        let colors = viewModel.colors
        let textBinding = Binding<String>(
            get: { viewModel.textValues[field.id] ?? "" },
            set: { viewModel.updateText($0, for: field) }
        )

        VStack(alignment: .leading, spacing: 8) {
            //label(colors: colors)

            switch field.subtype ?? FieldSubtype.plain {
            case FieldSubtype.multiline:
                FieldHeaderView(field: field, viewModel: viewModel)
                ZStack(alignment: .topLeading) {
                    if textBinding.wrappedValue.isEmpty, let placeholder = field.placeholder {
                        Text(placeholder)
                            .foregroundColor(Color(hex: colors.textHex, fallback: .secondary).opacity(0.55))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                    }

                    TextEditor(text: textBinding)
                        .focused(isTextInputFocused)
                        .frame(minHeight: 96)
                        .scrollContentBackground(.hidden)
                        .foregroundColor(Color(hex: colors.textHex, fallback: .primary))
                        .padding(8)
                }
                .background(fieldBackground)
                .overlay(fieldBorder(colors: colors))
            case FieldSubtype.secure:
                FieldHeaderView(field: field, viewModel: viewModel)
                SecureField(field.placeholder ?? "", text: $secureText)
                    .focused(isTextInputFocused)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(fieldBackground)
                    .foregroundColor(Color(hex: colors.textHex, fallback: .primary))
                    .overlay(fieldBorder(colors: colors))
                    .onAppear {
                        secureText = viewModel.textValues[field.id] ?? ""
                    }
                    .onChange(of: secureText) { newValue in
                        let limitedValue = limitedText(newValue)

                        if secureText != limitedValue {
                            secureText = limitedValue
                        }

                        viewModel.updateText(limitedValue, for: field)
                    }
                    .onChange(of: viewModel.textValues[field.id] ?? "") { newValue in
                        if secureText != newValue {
                            secureText = newValue
                        }
                    }
            case FieldSubtype.number:
                FieldHeaderView(field: field, viewModel: viewModel)
                TextField(field.placeholder ?? "", text: textBinding)
                    .focused(isTextInputFocused)
                    .keyboardType(.decimalPad)
                    .padding(12)
                    .background(fieldBackground)
                    .foregroundColor(Color(hex: colors.textHex, fallback: .primary))
                    .overlay(fieldBorder(colors: colors))
            case FieldSubtype.uri:
                FieldHeaderView(field: field, viewModel: viewModel)
                TextField(field.placeholder ?? "", text: textBinding)
                    .focused(isTextInputFocused)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(fieldBackground)
                    .foregroundColor(Color(hex: colors.textHex, fallback: .primary))
                    .overlay(fieldBorder(colors: colors))
            case FieldSubtype.plain:
                FieldHeaderView(field: field, viewModel: viewModel)
                TextField(field.placeholder ?? "", text: textBinding)
                    .focused(isTextInputFocused)
                    .padding(12)
                    .background(fieldBackground)
                    .foregroundColor(Color(hex: colors.textHex, fallback: .primary))
                    .overlay(fieldBorder(colors: colors))
            default:
                EmptyView()
            }

            if let maxLength = field.maxLength {
                Text("\(textBinding.wrappedValue.count)/\(maxLength)")
                    .font(.caption)
                    .foregroundColor(Color(hex: colors.textHex, fallback: .secondary).opacity(0.75))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private func limitedText(_ value: String) -> String {
        guard let maxLength = field.maxLength else {
            return value
        }

        return String(value.prefix(maxLength))
    }

    private var fieldBackground: some View {
        Color(.secondarySystemBackground).opacity(0.18)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func fieldBorder(colors: FormColors) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color(hex: colors.borderHex, fallback: Color(.separator)), lineWidth: 1)
    }

}
