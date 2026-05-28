import SwiftUI

struct DropdownField: View {
    let field: FormField
    @ObservedObject var viewModel: DynamicFormViewModel
    @State private var isSingleSelectionExpanded = false
    @State private var isMultipleSelectionExpanded = false

    var body: some View {
        if field.allowMultiple == true {
            multipleSelectionView
        } else {
            singleSelectionView
        }
    }

    private var multipleSelectionView: some View {
        let colors = viewModel.colors
        let options = field.options ?? []

        return VStack(alignment: .leading, spacing: 10) {
//            fieldLabel(colors: colors)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isMultipleSelectionExpanded.toggle()
                }
            } label: {
                dropdownLabel(text: selectedLabelsText, colors: colors)
            }
            .buttonStyle(.plain)

            if isMultipleSelectionExpanded {
                VStack(spacing: 0) {
                    ForEach(options) { option in
                        CheckboxRow(
                            title: option.label,
                            isSelected: viewModel.selectedOptionIDs[field.id, default: []].contains(option.id),
                            colors: colors
                        ) {
                            viewModel.toggleOption(option.id, for: field.id)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)

                        if option.id != options.last?.id {
                            Divider()
                        }
                    }
                }
                .background(Color(.secondarySystemBackground).opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(fieldBorder(colors: colors))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var singleSelectionView: some View {
        let colors = viewModel.colors
        let options = field.options ?? []

        return VStack(alignment: .leading, spacing: 8) {
//            fieldLabel(colors: colors)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isSingleSelectionExpanded.toggle()
                }
            } label: {
                dropdownLabel(text: selectedLabelsText, colors: colors)
            }
            .buttonStyle(.plain)

            if isSingleSelectionExpanded {
                VStack(spacing: 0) {
                    ForEach(options) { option in
                        Button {
                            viewModel.selectSingleOption(option.id, for: field.id)
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isSingleSelectionExpanded = false
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Text(option.label)
                                    .foregroundColor(Color(hex: colors.textHex, fallback: .primary))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                if isSelected(option) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color(hex: colors.borderHex, fallback: .accentColor))
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 12)
                        }
                        .buttonStyle(.plain)

                        if option.id != options.last?.id {
                            Divider()
                        }
                    }
                }
                .background(Color(.secondarySystemBackground).opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(fieldBorder(colors: colors))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var selectedLabelsText: String {
        let selectedIDs = viewModel.selectedOptionIDs[field.id, default: []]
        let selectedLabels = (field.options ?? [])
            .filter { selectedIDs.contains($0.id) }
            .map(\.label)

        return selectedLabels.isEmpty ? "Select" : selectedLabels.joined(separator: ", ")
    }

    private var isExpanded: Bool {
        field.allowMultiple == true ? isMultipleSelectionExpanded : isSingleSelectionExpanded
    }

    private func isSelected(_ option: FormOption) -> Bool {
        viewModel.selectedOptionIDs[field.id, default: []].contains(option.id)
    }

    private func dropdownLabel(text: String, colors: FormColors) -> some View {
        HStack {
            Text(text)
                .foregroundColor(Color(hex: colors.textHex, fallback: .primary))
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer()

            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                .foregroundColor(Color(hex: colors.textHex, fallback: .secondary))
        }
        .padding(12)
        .background(Color(.secondarySystemBackground).opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(fieldBorder(colors: colors))
    }

    private func fieldLabel(colors: FormColors) -> some View {
        Text(field.label)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(Color(hex: colors.textHex, fallback: .primary))
            .fixedSize(horizontal: false, vertical: true)
    }

    private func fieldBorder(colors: FormColors) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color(hex: colors.borderHex, fallback: Color(.separator)), lineWidth: 1)
    }
}
