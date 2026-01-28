//
//  CategoryPopover.swift
//  MyFirstApp
//

import SwiftUI

struct CategoryPopover: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedCategory: ExpenseCategory?
    let onDismiss: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]

    var body: some View {
        VStack(spacing: Spacing.md) {
            // Header
            Text("CATEGORY".letterSpaced)
                .font(ReceiptTypography.titleSmall)
                .foregroundStyle(ReceiptColors.inkFaded(for: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)

            DottedDivider(color: ReceiptColors.inkLight(for: colorScheme))

            // Category Grid
            LazyVGrid(columns: columns, spacing: Spacing.sm) {
                // None option
                CategoryItem(
                    icon: "xmark.circle",
                    label: "None",
                    isSelected: selectedCategory == nil
                ) {
                    HapticManager.chipSelect()
                    selectedCategory = nil
                    onDismiss()
                }

                // All categories
                ForEach(ExpenseCategory.allCases) { category in
                    CategoryItem(
                        icon: category.icon,
                        label: category.displayName,
                        isSelected: selectedCategory == category
                    ) {
                        HapticManager.chipSelect()
                        selectedCategory = category
                        onDismiss()
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(ReceiptColors.paper(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.medium)
                .stroke(ReceiptColors.inkLight(for: colorScheme).opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Category Item
private struct CategoryItem: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(
                        isSelected
                            ? ReceiptColors.ink(for: colorScheme)
                            : ReceiptColors.inkFaded(for: colorScheme)
                    )

                Text(label.uppercased())
                    .font(ReceiptTypography.captionSmall)
                    .foregroundStyle(
                        isSelected
                            ? ReceiptColors.ink(for: colorScheme)
                            : ReceiptColors.inkLight(for: colorScheme)
                    )
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                isSelected
                    ? ReceiptColors.paperAlt(for: colorScheme)
                    : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .stroke(
                        isSelected
                            ? ReceiptColors.inkFaded(for: colorScheme)
                            : ReceiptColors.inkLight(for: colorScheme).opacity(0.3),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(ReceiptButtonStyle())
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selected: ExpenseCategory? = .dining

        var body: some View {
            CategoryPopover(selectedCategory: $selected) {}
                .padding()
                .background(Color(.systemGroupedBackground))
        }
    }

    return PreviewWrapper()
}
