import Combine
import Foundation

struct FormColors {
    let backgroundHex: String?
    let textHex: String?
    let borderHex: String?
    let errorHex: String?

    static let fallback = FormColors(
        backgroundHex: nil,
        textHex: nil,
        borderHex: nil,
        errorHex: nil
    )
}

@MainActor
final class DynamicFormViewModel: ObservableObject {
    @Published private(set) var schema: FormSchema?
    @Published private(set) var visibleFields: [FormField] = []
    @Published var textValues: [String: String] = [:]
    @Published var selectedOptionIDs: [String: Set<String>] = [:]
    @Published var boolValues: [String: Bool] = [:]
    @Published var errors: [String: String] = [:]
    @Published var loadErrorMessage: String?
    @Published var didSubmitSuccessfully = false
    @Published var submittedValuesMessage = ""
    @Published var isFormSchemeValid = true

    var formTitle: String {
        schema?.formTitle ?? "Dynamic Form"
    }

    var colors: FormColors {
        guard let theme = schema?.theme else {
            return .fallback
        }

        return FormColors(
            backgroundHex: theme.backgroundColor,
            textHex: theme.textColor,
            borderHex: theme.borderColor,
            errorHex: theme.errorColor
        )
    }

    func loadForm() {
        do {
            guard let url = Bundle.main.url(forResource: "DynamicForm", withExtension: "json") else {
                throw FormLoadingError.missingFile
            }

            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedSchema = try decoder.decode(FormSchema.self, from: data)
            isFormSchemeValid = true
            apply(schema: decodedSchema)
        } catch {
            isFormSchemeValid = false
            loadErrorMessage = "Unable to load the form. Please check the bundled JSON file."
      }
    }

    func updateText(_ value: String, for field: FormField) {
        var sanitizedValue = value

        if field.subtype == FieldSubtype.number {
            sanitizedValue = sanitizeNumber(sanitizedValue)
        }

        if let maxLength = field.maxLength {
            sanitizedValue = String(sanitizedValue.prefix(maxLength))
        }

        if textValues[field.id] == sanitizedValue, value != sanitizedValue {
            objectWillChange.send()
        }

        textValues[field.id] = sanitizedValue
        errors[field.id] = nil
    }

    func toggleOption(_ optionID: String, for fieldID: String) {
        var selectedIDs = selectedOptionIDs[fieldID, default: []]

        if selectedIDs.contains(optionID) {
            selectedIDs.remove(optionID)
        } else {
            selectedIDs.insert(optionID)
        }

        selectedOptionIDs[fieldID] = selectedIDs
        errors[fieldID] = nil
    }

    func selectSingleOption(_ optionID: String, for fieldID: String) {
        selectedOptionIDs[fieldID] = [optionID]
        errors[fieldID] = nil
    }

    func updateBool(_ value: Bool, for fieldID: String) {
        boolValues[fieldID] = value
        errors[fieldID] = nil
    }

    func clearLoadError() {
        loadErrorMessage = nil
    }

    func submit() {
        var validationErrors: [String: String] = [:]

        for field in visibleFields {
            guard field.required == true else {
                continue
            }

            switch field.type {
            case FieldType.text:
                let value = textValues[field.id]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if value.isEmpty {
                    validationErrors[field.id] = errorMessage(for: field)
                } else if field.subtype == FieldSubtype.number && !isValidNumber(value) {
                    validationErrors[field.id] = errorMessage(for: field)
                }
            case FieldType.dropdown:
                if selectedOptionIDs[field.id, default: []].isEmpty {
                    validationErrors[field.id] = errorMessage(for: field)
                }
            case FieldType.checkbox:
                if boolValues[field.id] != true {
                    validationErrors[field.id] = errorMessage(for: field)
                }
            default:
                break
            }
        }

        errors = validationErrors

        if validationErrors.isEmpty {
            submittedValuesMessage = formattedSubmittedValues()
            initializeValues(for: visibleFields)
            didSubmitSuccessfully = true
        } else {
            didSubmitSuccessfully = false
        }
    }

    private func apply(schema: FormSchema) {
        self.schema = schema
        let supportedFields = sortedFieldsPreservingJSONOrder(from: schema.fields).filter { field in
            guard let type = field.type, FieldType.supported.contains(type) else {
                return false
            }

            if type == FieldType.text, let subtype = field.subtype {
                return FieldSubtype.supported.contains(subtype)
            }

            if type == FieldType.dropdown {
                return field.options?.isEmpty == false
            }

            return true
        }

        visibleFields = supportedFields
        initializeValues(for: supportedFields)
    }

    private func sortedFieldsPreservingJSONOrder(from fields: [FormField]) -> [FormField] {
        fields
            .enumerated()
            .sorted { lhs, rhs in
                let lhsOrder = lhs.element.order ?? Int.max
                let rhsOrder = rhs.element.order ?? Int.max

                if lhsOrder == rhsOrder {
                    return lhs.offset < rhs.offset
                }

                return lhsOrder < rhsOrder
            }
            .map(\.element)
    }

    private func formattedSubmittedValues() -> String {
        let lines = visibleFields.map { field in
            "  \"\(field.id)\": \(submittedValueDescription(for: field))"
        }

        return "{\n" + lines.joined(separator: ",\n") + "\n}"
    }

    private func submittedValueDescription(for field: FormField) -> String {
        switch field.type {
        case FieldType.text:
            return quoted(textValues[field.id] ?? "")
        case FieldType.dropdown:
            return dropdownValueDescription(for: field)
        case FieldType.toggle, FieldType.checkbox:
            return boolValues[field.id] == true ? "true" : "false"
        default:
            return "null"
        }
    }

    private func dropdownValueDescription(for field: FormField) -> String {
        let selectedIDs = selectedOptionIDs[field.id, default: []]
        let orderedSelectedIDs = (field.options ?? [])
            .map(\.id)
            .filter { selectedIDs.contains($0) }

        if field.allowMultiple == true {
            return "[" + orderedSelectedIDs.map(quoted).joined(separator: ", ") + "]"
        }

        return quoted(orderedSelectedIDs.first ?? "")
    }

    private func quoted(_ value: String) -> String {
        "\"\(escaped(value))\""
    }

    private func escaped(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
    }

    private func initializeValues(for fields: [FormField]) {
        textValues = [:]
        selectedOptionIDs = [:]
        boolValues = [:]
        errors = [:]
        didSubmitSuccessfully = false

        for field in fields {
            switch field.type {
            case FieldType.text:
                let defaultText = field.defaultValue?.stringValue ?? ""
                if let maxLength = field.maxLength {
                    textValues[field.id] = String(defaultText.prefix(maxLength))
                } else {
                    textValues[field.id] = defaultText
                }
            case FieldType.toggle, FieldType.checkbox:
                boolValues[field.id] = field.defaultValue?.boolValue ?? false
            case FieldType.dropdown:
                if let defaultIDs = field.defaultValue?.stringArrayValue {
                    selectedOptionIDs[field.id] = Set(defaultIDs)
                } else if let defaultID = field.defaultValue?.stringValue {
                    selectedOptionIDs[field.id] = [defaultID]
                } else {
                    selectedOptionIDs[field.id] = []
                }
            default:
                break
            }
        }
    }

    private func sanitizeNumber(_ value: String) -> String {
        var result = ""
        var hasDecimalSeparator = false
        var decimalCount = 0

        for character in value {
            if character.isNumber {
                if hasDecimalSeparator {
                    guard decimalCount < 2 else {
                        continue
                    }
                    decimalCount += 1
                }
                result.append(character)
            } else if character == "." && !hasDecimalSeparator {
                hasDecimalSeparator = true
                result.append(character)
            }
        }

        return result
    }

    private func isValidNumber(_ value: String) -> Bool {
        value.range(of: #"^\d+(\.\d{1,2})?$"#, options: .regularExpression) != nil
    }

    private func errorMessage(for field: FormField) -> String {
        field.errorMessage ?? "This field is required."
    }
}

private enum FormLoadingError: Error {
    case missingFile
}
