import SwiftUI

struct TemplateListView: View {
    @StateObject private var viewModel = TemplateListViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showSaveSheet = false
    @State private var templateName = ""

    var currentAnnotations: [Annotation] = []
    var onApply: (([Annotation]) -> Void)?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.templates.isEmpty {
                    ContentUnavailableView(
                        "No Templates",
                        systemImage: "square.grid.2x2",
                        description: Text("Save your annotation setup as a template for reuse")
                    )
                } else {
                    List {
                        ForEach(viewModel.templates) { template in
                            Button {
                                onApply?(template.annotations)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(template.name)
                                        .font(.headline)
                                    Text("\(template.annotations.count) annotations")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Text(template.createdAt, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteTemplate(viewModel.templates[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSaveSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(currentAnnotations.isEmpty)
                }
            }
            .alert("Save Template", isPresented: $showSaveSheet) {
                TextField("Template name", text: $templateName)
                Button("Save") {
                    if !templateName.isEmpty {
                        viewModel.saveTemplate(name: templateName, annotations: currentAnnotations)
                        templateName = ""
                    }
                }
                Button("Cancel", role: .cancel) { templateName = "" }
            } message: {
                Text("Enter a name for this template")
            }
        }
    }
}
