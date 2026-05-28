import SwiftUI

struct CheckboxField: View {
    let field: FormField
    @ObservedObject var viewModel: DynamicFormViewModel

    var body: some View {
        let colors = viewModel.colors
        let isSelected = viewModel.boolValues[field.id] ?? false

        CheckboxRow(title: field.label, isSelected: isSelected, colors: colors) {
            viewModel.updateBool(!isSelected, for: field.id)
        }
    }
}
