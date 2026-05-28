import Foundation

struct FormSchema: Codable {
    let theme: FormTheme
    let formTitle: String
    let fields: [FormField]
}

struct FormTheme: Codable {
    let backgroundColor: String?
    let textColor: String?
    let borderColor: String?
    let errorColor: String?
}

struct FormField: Codable, Identifiable {
    let id: String
    let order: Int?
    let type: String?
    let subtype: String?
    let label: String
    let placeholder: String?
    let defaultValue: FormDefaultValue?
    let maxLength: Int?
    let errorMessage: String?
    let required: Bool?
    let allowMultiple: Bool?
    let options: [FormOption]?
    let metadata: [String: String]?
}

struct FormOption: Codable, Identifiable, Equatable {
    let id: String
    let label: String
}

enum FormDefaultValue: Codable {
    case string(String)
    case bool(Bool)
    case stringArray([String])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let stringArrayValue = try? container.decode([String].self) {
            self = .stringArray(stringArrayValue)
        } else {
            self = .string(try container.decode(String.self))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .stringArray(let value):
            try container.encode(value)
        }
    }

    var stringValue: String? {
        if case .string(let value) = self {
            return value
        }
        return nil
    }

    var boolValue: Bool? {
        if case .bool(let value) = self {
            return value
        }
        return nil
    }

    var stringArrayValue: [String]? {
        if case .stringArray(let value) = self {
            return value
        }
        return nil
    }
}
