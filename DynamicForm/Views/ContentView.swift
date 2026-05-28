import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DynamicFormViewModel()
    @FocusState private var isTextInputFocused: Bool

    var body: some View {
        let colors = viewModel.colors

        ZStack {
            Color(hex: colors.backgroundHex, fallback: Color(.systemBackground))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text(viewModel.formTitle)
                            .font(.title2.weight(.semibold))
                            .foregroundColor(Color(hex: colors.textHex, fallback: .primary))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(Array(viewModel.visibleFields.enumerated()), id: \.offset) { _, field in
                            DynamicFieldView(
                                field: field,
                                viewModel: viewModel,
                                isTextInputFocused: $isTextInputFocused
                            )
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 96)
                }
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                isTextInputFocused = false
            }
        )
        .safeAreaInset(edge: .bottom) {
            submitFooter(colors: colors)
        }
        .onAppear {
            if viewModel.schema == nil {
                viewModel.loadForm()
            }
        }
        .alert("Form Error", isPresented: Binding(
            get: { viewModel.loadErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.clearLoadError()
                }
            }
        )) {
            Button("OK", role: .cancel) {
                viewModel.clearLoadError()
            }
        } message: {
            Text(viewModel.loadErrorMessage ?? "Something went wrong.")
        }
        .alert("Form Submitted", isPresented: $viewModel.didSubmitSuccessfully) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.submittedValuesMessage)
        }
    }

    private func submitFooter(colors: FormColors) -> some View {
        VStack(spacing: 0) {
            Divider()
            Button {
                viewModel.submit()
            } label: {
                Text("Submit")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .disabled(!viewModel.isFormSchemeValid)
            .buttonStyle(.borderedProminent)
            .tint(viewModel.isFormSchemeValid ? Color(.systemBlue) : Color(.systemBlue).opacity(0.2))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color(hex: colors.backgroundHex, fallback: Color(.systemBackground)))
    }
}

#Preview {
    ContentView()
}
