enum FieldType {
    static let text = "TEXT"
    static let dropdown = "DROPDOWN"
    static let toggle = "TOGGLE"
    static let checkbox = "CHECKBOX"

    static let supported = [text, dropdown, toggle, checkbox]
}

enum FieldSubtype {
    static let plain = "PLAIN"
    static let multiline = "MULTILINE"
    static let number = "NUMBER"
    static let uri = "URI"
    static let secure = "SECURE"

    static let supported = [plain, multiline, number, uri, secure]
}
