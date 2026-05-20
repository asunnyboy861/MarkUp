import SwiftUI
import Photos

struct BatchEditView: View {
    let images: [UIImage]
    @StateObject private var viewModel = BatchEditViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0
    @State private var isProcessing = false
    @State private var processedCount = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if images.isEmpty {
                    ContentUnavailableView(
                        "No Images",
                        systemImage: "photo.on.rectangle.angled"
                    )
                } else {
                    TabView(selection: $currentIndex) {
                        ForEach(0..<images.count, id: \.self) { index in
                            Image(uiImage: images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(maxHeight: .infinity)

                    VStack(spacing: 12) {
                        Text("Image \(currentIndex + 1) of \(images.count)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 16) {
                            Button {
                                applyToCurrent()
                            } label: {
                                Label("Apply to This", systemImage: "checkmark.circle")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)

                            Button {
                                applyToAll()
                            } label: {
                                Label("Apply to All", systemImage: "checkmark.circle.trianglebadge.exclamationmark")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Batch Edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") { dismiss() }
                        .disabled(isProcessing)
                }
            }
            .overlay {
                if isProcessing {
                    Color.black.opacity(0.3)
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Processing \(processedCount)/\(images.count)...")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }

    private func applyToCurrent() {
        viewModel.applyAnnotations(to: images[currentIndex])
    }

    private func applyToAll() {
        isProcessing = true
        Task {
            for (index, image) in images.enumerated() {
                viewModel.applyAnnotations(to: image)
                processedCount = index + 1
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            isProcessing = false
        }
    }
}
