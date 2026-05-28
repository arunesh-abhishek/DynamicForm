//
//  FieldHeaderView.swift
//  EulerityAssignment
//
//  Created by Arunesh Abhishek on 26/05/26.
//

import SwiftUI

struct FieldHeaderView: View {
    let field: FormField
    @ObservedObject var viewModel: DynamicFormViewModel
    var body: some View {
        Text(field.label)
            .font(.subheadline.weight(.semibold))
            .foregroundColor(Color(hex: viewModel.colors.textHex, fallback: .primary))
            .fixedSize(horizontal: false, vertical: true)
    }
}

