import SwiftUI
import Photos

struct EditorView: View {
    let sourceImage: UIImage
    @StateObject private var viewModel: EditorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showExportSheet = false
    @State private var showPaywall = false

    init(sourceImage: UIImage) {
        self.sourceImage = sourceImage
        self._viewModel = StateObject(wrappedValue: EditorViewModel(sourceImage: sourceImage))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GeometryReader { geometry in
                VStack(spacing: 0) {
                    topBar
                    canvasArea(geometry: geometry)
                    toolBar
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showExportSheet) {
            ExportSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }

            Spacer()

            Button {
                viewModel.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .disabled(viewModel.undoStack.isEmpty)

            Button {
                viewModel.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .disabled(viewModel.redoStack.isEmpty)

            Spacer()

            Button {
                showExportSheet = true
            } label: {
                Text("Done")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func canvasArea(geometry: GeometryProxy) -> some View {
        ZStack {
            Image(uiImage: sourceImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            CanvasOverlayView(viewModel: viewModel, imageSize: sourceImage.size)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var toolBar: some View {
        VStack(spacing: 8) {
            if viewModel.showColorPicker {
                ColorPickerBar(viewModel: viewModel)
            }

            if viewModel.showLineWidthSlider {
                LineWidthSlider(viewModel: viewModel)
            }

            if viewModel.showOpacitySlider {
                OpacitySlider(viewModel: viewModel)
            }

            if viewModel.showShapePicker {
                ShapePickerBar(viewModel: viewModel)
            }

            if viewModel.showBlurTypePicker {
                BlurTypePickerBar(viewModel: viewModel)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ToolType.allCases, id: \.self) { tool in
                        ToolButton(
                            tool: tool,
                            isSelected: viewModel.currentTool == tool,
                            action: { viewModel.selectTool(tool) }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }

            HStack(spacing: 16) {
                Button {
                    viewModel.toggleColorPicker()
                } label: {
                    Circle()
                        .fill(viewModel.currentColor.color)
                        .frame(width: 32, height: 32)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }

                Button {
                    viewModel.toggleLineWidthSlider()
                } label: {
                    Image(systemName: "lineweight")
                        .font(.title3)
                        .foregroundStyle(.white)
                }

                Button {
                    viewModel.toggleOpacitySlider()
                } label: {
                    Image(systemName: "circle.lefthalf.filled")
                        .font(.title3)
                        .foregroundStyle(.white)
                }

                if viewModel.currentTool == .shape {
                    Button {
                        viewModel.toggleShapePicker()
                    } label: {
                        Image(systemName: "square.on.square")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }

                if viewModel.currentTool == .blur {
                    Button {
                        viewModel.toggleBlurTypePicker()
                    } label: {
                        Image(systemName: "rectangle.dashed.badge.record")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }

                Spacer()

                if viewModel.currentTool == .shape {
                    Button {
                        viewModel.toggleFillMode()
                    } label: {
                        Image(systemName: viewModel.isFilled ? "square.fill" : "square")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(Color.black.opacity(0.85))
    }
}

struct ToolButton: View {
    let tool: ToolType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tool.systemImageName)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .blue : .white)
                Text(tool.displayName)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .blue : .white.opacity(0.7))
            }
            .frame(width: 56, height: 52)
            .background(isSelected ? Color.white.opacity(0.15) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct ColorPickerBar: View {
    @ObservedObject var viewModel: EditorViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(CodableColor.presetColors, id: \.self) { color in
                    Button {
                        viewModel.selectColor(color)
                    } label: {
                        Circle()
                            .fill(color.color)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(viewModel.currentColor == color ? Color.white : Color.clear, lineWidth: 2)
                            )
                    }
                }

                ColorPicker("", selection: Binding(
                    get: { viewModel.currentColor.color },
                    set: { viewModel.selectColor(CodableColor(color: $0)) }
                ))
                .labelsHidden()
                .frame(width: 32, height: 32)
            }
            .padding(.horizontal, 16)
        }
    }
}

struct LineWidthSlider: View {
    @ObservedObject var viewModel: EditorViewModel

    var body: some View {
        HStack {
            Text("Width")
                .font(.caption)
                .foregroundStyle(.white)
            Slider(value: $viewModel.currentLineWidth, in: 1...30, step: 1)
                .tint(.white)
            Text("\(Int(viewModel.currentLineWidth))pt")
                .font(.caption)
                .foregroundStyle(.white)
                .frame(width: 40)
        }
        .padding(.horizontal, 16)
    }
}

struct OpacitySlider: View {
    @ObservedObject var viewModel: EditorViewModel

    var body: some View {
        HStack {
            Text("Opacity")
                .font(.caption)
                .foregroundStyle(.white)
            Slider(value: $viewModel.currentOpacity, in: 0.05...1.0, step: 0.05)
                .tint(.white)
            Text("\(Int(viewModel.currentOpacity * 100))%")
                .font(.caption)
                .foregroundStyle(.white)
                .frame(width: 40)
        }
        .padding(.horizontal, 16)
    }
}

struct ShapePickerBar: View {
    @ObservedObject var viewModel: EditorViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ShapeType.allCases, id: \.self) { shape in
                    Button {
                        viewModel.selectShapeType(shape)
                    } label: {
                        Image(systemName: shapeSystemImage(shape))
                            .font(.title3)
                            .foregroundStyle(viewModel.currentShapeType == shape ? .blue : .white)
                            .frame(width: 44, height: 44)
                            .background(viewModel.currentShapeType == shape ? Color.white.opacity(0.15) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func shapeSystemImage(_ shape: ShapeType) -> String {
        switch shape {
        case .circle: return "circle"
        case .rectangle: return "rectangle"
        case .triangle: return "triangle"
        case .star: return "star"
        case .chatBubble: return "bubble.left"
        }
    }
}

struct BlurTypePickerBar: View {
    @ObservedObject var viewModel: EditorViewModel

    var body: some View {
        HStack(spacing: 16) {
            Button {
                viewModel.selectBlurType(.gaussian)
            } label: {
                Text("Blur")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(viewModel.currentBlurType == .gaussian ? .blue : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(viewModel.currentBlurType == .gaussian ? Color.white.opacity(0.15) : Color.clear)
                    .clipShape(Capsule())
            }

            Button {
                viewModel.selectBlurType(.pixelate)
            } label: {
                Text("Pixelate")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(viewModel.currentBlurType == .pixelate ? .blue : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(viewModel.currentBlurType == .pixelate ? Color.white.opacity(0.15) : Color.clear)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
    }
}

struct ExportSheet: View {
    @ObservedObject var viewModel: EditorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isExporting = false

    var body: some View {
        NavigationStack {
            List {
                Section("Export Format") {
                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Button {
                            Task {
                                isExporting = true
                                if format == .pdf && !viewModel.purchaseManager.isPro {
                                    dismiss()
                                    viewModel.showPaywallFromExport = true
                                    isExporting = false
                                    return
                                }
                                _ = await viewModel.exportAndSave(format: format)
                                isExporting = false
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Image(systemName: format == .png ? "photo" : format == .jpg ? "photo.artframe" : "doc.richtext")
                                Text(format.displayName)
                                if format == .pdf {
                                    Spacer()
                                    Text("PRO")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }

                Section("Save") {
                    Button {
                        Task {
                            isExporting = true
                            _ = await viewModel.exportAndSave(format: .png)
                            isExporting = false
                            dismiss()
                        }
                    } label: {
                        Label("Save to Photos", systemImage: "square.and.arrow.down")
                    }
                }
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay {
                if isExporting {
                    Color.black.opacity(0.3)
                    ProgressView()
                }
            }
        }
    }
}
