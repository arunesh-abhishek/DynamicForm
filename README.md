# Dynamic Form

Single-screen SwiftUI application that renders a dynamic form from a bundled local JSON file.

## Overview

The app reads `Resources/DynamicForm.json` from the app bundle, decodes it into Codable models, and renders form fields dynamically based on the JSON schema. The UI supports text inputs, dropdowns, toggles, and checkboxes. Field state is stored centrally in an observable view model, and validation runs when the user submits the form.

The implementation follows an MVVM structure with a small set of reusable SwiftUI views for each field type.

## Architecture

```text
EulerityAssignment/
├── App/
│   └── EulerityAssignmentApp.swift
├── Models/
│   ├── FormSchema.swift
│   └── FormConstants.swift
├── ViewModels/
│   └── DynamicFormViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── DynamicFieldView.swift
│   ├── TextInputField.swift
│   ├── DropdownField.swift
│   ├── ToggleField.swift
│   ├── CheckboxField.swift
│   ├── CheckboxRow.swift
│   ├── FieldHeaderView.swift
│   └── ColorHex.swift
└── Resources/
    ├── Assets.xcassets
    └── DynamicForm.json
```

## Model Layer

`FormSchema.swift` contains simple `Codable` models that mirror the JSON structure using Swift-style camelCase properties. The JSON decoder uses `.convertFromSnakeCase`, allowing keys like `form_title`, `default_value`, and `max_length` to map cleanly to Swift properties.

`FormDefaultValue` supports the mixed value types currently needed by the schema:

- `String`
- `Bool`
- `[String]`

This allows text defaults, toggle/checkbox defaults, and dropdown selected-id defaults.

`FormConstants.swift` centralizes supported field type and subtype strings so rendering logic does not scatter raw string literals throughout the app.

## View Model Layer

`DynamicFormViewModel` is the source of truth for form state. It is an `ObservableObject` with published state dictionaries:

- `textValues: [String: String]`
- `selectedOptionIDs: [String: Set<String>]`
- `boolValues: [String: Bool]`
- `errors: [String: String]`

The view model handles:

- Loading `DynamicForm.json` from the app bundle.
- Decoding the schema.
- Filtering unsupported field types and invalid text subtypes.
- Hiding dropdowns with empty option arrays.
- Sorting fields by `order`, while preserving original JSON order for equal order values.
- Initializing default field values.
- Sanitizing numeric input to allow up to two decimal places.
- Validating required fields on submit.
- Formatting submitted values as JSON-like key/value output.
- Resetting the form to default values after successful submission.
- Exposing a user-facing error if JSON loading fails.

Unsupported field types are ignored so malformed or future schema additions do not crash the app.

## View Layer

`ContentView` renders the main screen:

- Form title.
- Dynamic field list.
- Fixed bottom Submit button.
- Loading/error alert.
- Successful submission alert.

`DynamicFieldView` dispatches each field to the correct SwiftUI field view.

Field-specific views:

- `TextInputField`: supports `PLAIN`, `MULTILINE`, `NUMBER`, `URI`, and `SECURE`.
- `DropdownField`: supports single select with native `Menu` and multi-select with a custom non-dismissing checkbox panel.
- `ToggleField`: renders toggle controls.
- `CheckboxField`: renders standalone checkbox controls.
- `CheckboxRow`: reusable checkbox row used by standalone checkboxes and multi-select dropdown options.
- `FieldHeaderView`: shared field label/header rendering.

Invalid text subtypes are filtered before rendering, so they do not take layout space.

## Supported JSON Field Types

### TEXT

Supported subtypes:

- `PLAIN`
- `MULTILINE`
- `NUMBER`
- `URI`
- `SECURE`

`NUMBER` input is sanitized to allow digits and one decimal separator with up to two decimal places.

### DROPDOWN

If `allow_multiple` is `false`, the field renders as a native SwiftUI `Menu`.

If `allow_multiple` is `true`, the field renders as a custom dropdown panel with checkbox rows. This avoids the native `Menu` behavior where the menu dismisses after every selection.

Selections are tracked by option id.

### TOGGLE

Boolean state is tracked in the view model by field id.

### CHECKBOX

Boolean state is tracked in the view model by field id.

## Validation

Validation runs only after tapping Submit.

Required fields are validated as follows:

- Text: must not be empty.
- Number: must match the accepted numeric format.
- Dropdown: must have at least one selected option.
- Checkbox: must be checked.
- Toggle: currently does not block submission.

Errors are shown below each field.

## Submission

On successful submission, the app shows an alert containing valid key/value pairs for each visible field, preserving data types where appropriate:

```json
{
  "campaign_name": "Summer Sale",
  "target_network": ["net_meta"],
  "accept_legal": true
}
```

After successful submission, the form resets to its default JSON-defined values.

## Theming

The JSON theme includes hex values for background, text, border, and error colors. `ColorHex.swift` converts supported hex strings into SwiftUI `Color` values with system fallbacks.

Current behavior still uses JSON theme colors where applied. Further refinement can make the UI more adaptive to light and dark mode by leaning more heavily on system colors for surfaces and text.

## Build

The project uses SwiftUI and no third-party dependencies.

Minimum deployment target: iOS 16.0.

Validation was performed using Xcode build tooling after major changes.

## Product Decisions
- In case of unsupported field type, an empty view is used so that app doesn't crash.
- The form field is reset to it's default values after successful submission so that new form can be submitted.
- In case the duplicate order value are present in JSON, the form doesn't discard the duplicate one. Instead it preserves the original JSON order for equal order values. This means, they would be should one after the another. 
- In case order value of a specific field is missing, by default a maximum value is assigned to that field so that app doesn't crash in case of missing value. 
- If the JSON has a type as dropdown with required field, but dropdown has no options to show(option array is empty), the dropdown is not rendered on UI in this case allowing user to submit the form successfully.
- In case the default value of the field exceeds the max_length if present in the JSON, the default value is truncated.


## Future Scope

- The form currently supports four types of fields - text, dropdown, toggle, checkbox. It should be enhanced to support other fields like Date Picker as well.
- It should also allow user to upload documents. This could be driven by module. If the module to upload document is enabled, the upload document field would be shown.
- The form should be made compatible with dark/light mode.

 
 

