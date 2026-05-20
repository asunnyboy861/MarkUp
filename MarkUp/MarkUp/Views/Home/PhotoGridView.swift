import SwiftUI
import Photos

struct PhotoGridView: View {
    @StateObject private var viewModel = PhotoGridViewModel()
    @State private var selectedImage: UIImage?
    @State private var showEditor = false
    @State private var showCamera = false
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Album", selection: $selectedTab) {
                    Text("Photos").tag(0)
                    Text("Screenshots").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading photos...")
                    Spacer()
                } else if viewModel.photos.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        "No Photos",
                        systemImage: "photo.on.rectangle.angled",
                        description: Text("Allow photo access to start annotating")
                    )
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 2),
                            GridItem(.flexible(), spacing: 2),
                            GridItem(.flexible(), spacing: 2)
                        ], spacing: 2) {
                            ForEach(viewModel.photos, id: \.localIdentifier) { asset in
                                PhotoCell(asset: asset) { image in
                                    selectedImage = image
                                    showEditor = true
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("MarkUp")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showCamera = true
                    } label: {
                        Label("Camera", systemImage: "camera")
                    }
                }
            }
            .fullScreenCover(isPresented: $showEditor) {
                if let image = selectedImage {
                    EditorView(sourceImage: image)
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView { image in
                    selectedImage = image
                    showEditor = true
                }
            }
            .task {
                await viewModel.loadPhotos()
            }
            .onChange(of: selectedTab) { _, newValue in
                Task {
                    await viewModel.loadPhotos(screenshotsOnly: newValue == 1)
                }
            }
        }
    }
}

struct PhotoCell: View {
    let asset: PHAsset
    let onSelect: (UIImage) -> Void
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 120, maxHeight: 120)
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelect(image)
                    }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 120, maxHeight: 120)
            }
        }
        .task {
            let targetSize = CGSize(width: 200, height: 200)
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { result, _ in
                if let result {
                    self.image = result
                }
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage) -> Void

        init(onCapture: @escaping (UIImage) -> Void) {
            self.onCapture = onCapture
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onCapture(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
