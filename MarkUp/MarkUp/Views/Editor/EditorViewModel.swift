import SwiftUI
import Combine

@MainActor
class EditorViewModel: ObservableObject {
    let sourceImage: UIImage
    let purchaseManager = PurchaseManager()
    let toolMemory = ToolMemoryService()

    @Published var annotations: [Annotation] = []
    @Published var undoStack: [[Annotation]] = []
    @Published var redoStack: [[Annotation]] = []
    @Published var currentTool: ToolType = .pen
    @Published var currentColor: CodableColor = .red
    @Published var currentLineWidth: CGFloat = 2
    @Published var currentOpacity: Double = 1.0
    @Published var currentShapeType: ShapeType = .circle
    @Published var currentBlurType: BlurType = .gaussian
    @Published var isFilled: Bool = false
    @Published var showColorPicker = false
    @Published var showLineWidthSlider = false
    @Published var showOpacitySlider = false
    @Published var showShapePicker = false
    @Published var showBlurTypePicker = false
    @Published var showPaywallFromExport = false
    @Published var isDrawing = false

    private var currentDrawingAnnotation: Annotation?
    private var currentShapeAnnotation: Annotation?
    private var currentArrowAnnotation: Annotation?

    init(sourceImage: UIImage) {
        self.sourceImage = sourceImage
        self.currentTool = ToolType(rawValue: toolMemory.settings.lastTool) ?? .pen
        self.currentColor = toolMemory.settings.lastColor
        self.currentLineWidth = toolMemory.settings.lastLineWidth
        self.currentOpacity = toolMemory.settings.lastOpacity
        self.currentShapeType = toolMemory.settings.lastShapeType
        self.currentBlurType = toolMemory.settings.lastBlurType
    }

    func selectTool(_ tool: ToolType) {
        currentTool = tool
        currentLineWidth = tool.defaultLineWidth
        currentOpacity = tool.defaultOpacity
        toolMemory.updateTool(tool)

        showShapePicker = false
        showBlurTypePicker = false

        if tool == .shape {
            showShapePicker = true
        } else if tool == .blur {
            showBlurTypePicker = true
        }
    }

    func selectColor(_ color: CodableColor) {
        currentColor = color
        toolMemory.updateColor(color)
    }

    func selectShapeType(_ shapeType: ShapeType) {
        currentShapeType = shapeType
        toolMemory.updateShapeType(shapeType)
    }

    func selectBlurType(_ blurType: BlurType) {
        currentBlurType = blurType
        toolMemory.updateBlurType(blurType)
    }

    func toggleColorPicker() {
        showColorPicker.toggle()
        showLineWidthSlider = false
        showOpacitySlider = false
    }

    func toggleLineWidthSlider() {
        showLineWidthSlider.toggle()
        showColorPicker = false
        showOpacitySlider = false
    }

    func toggleOpacitySlider() {
        showOpacitySlider.toggle()
        showColorPicker = false
        showLineWidthSlider = false
    }

    func toggleShapePicker() {
        showShapePicker.toggle()
    }

    func toggleBlurTypePicker() {
        showBlurTypePicker.toggle()
    }

    func toggleFillMode() {
        isFilled.toggle()
    }

    func saveState() {
        undoStack.append(annotations)
        redoStack.removeAll()
        if undoStack.count > 50 {
            undoStack.removeFirst()
        }
    }

    func undo() {
        guard let previous = undoStack.popLast() else { return }
        redoStack.append(annotations)
        annotations = previous
    }

    func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(annotations)
        annotations = next
    }

    func handleDragStart(at point: CGPoint, imageSize: CGSize, viewSize: CGSize) {
        let scaledPoint = scalePoint(point, imageSize: imageSize, viewSize: viewSize)
        isDrawing = true
        saveState()

        switch currentTool {
        case .loupe:
            let annotation = Annotation(type: .loupe, position: scaledPoint, size: CGSize(width: 80, height: 80), color: currentColor, lineWidth: currentLineWidth, opacity: currentOpacity)
            currentShapeAnnotation = annotation
        case .shape:
            let annotation = Annotation(type: .shape, position: scaledPoint, size: .zero, color: currentColor, lineWidth: currentLineWidth, opacity: currentOpacity, isFilled: isFilled)
            var mut = annotation
            mut.shapeType = currentShapeType
            currentShapeAnnotation = mut
        case .arrow:
            let annotation = Annotation(type: .arrow, position: scaledPoint, color: currentColor, lineWidth: currentLineWidth, opacity: currentOpacity)
            var mut = annotation
            mut.startPoint = scaledPoint
            mut.endPoint = scaledPoint
            currentArrowAnnotation = mut
        case .text:
            let annotation = Annotation(type: .text, position: scaledPoint, color: currentColor, lineWidth: currentLineWidth, opacity: currentOpacity)
            var mut = annotation
            mut.text = "Text"
            mut.fontSize = 18
            annotations.append(mut)
        case .pen, .marker, .pencil:
            let drawingTool: DrawingTool = currentTool == .pen ? .pen : currentTool == .marker ? .marker : .pencil
            let annotation = Annotation(type: .drawing, position: scaledPoint, color: currentColor, lineWidth: currentLineWidth, opacity: currentOpacity)
            var mut = annotation
            mut.pathPoints = [PathPoint(x: scaledPoint.x, y: scaledPoint.y)]
            mut.drawingTool = drawingTool
            currentDrawingAnnotation = mut
        case .highlight:
            let annotation = Annotation(type: .highlight, position: scaledPoint, color: currentColor, lineWidth: currentLineWidth, opacity: currentOpacity)
            var mut = annotation
            mut.pathPoints = [PathPoint(x: scaledPoint.x, y: scaledPoint.y)]
            currentDrawingAnnotation = mut
        case .blur:
            let annotation = Annotation(type: .blur, position: scaledPoint, size: CGSize(width: currentLineWidth * 3, height: currentLineWidth * 3), color: currentColor, lineWidth: currentLineWidth, opacity: currentOpacity)
            var mut = annotation
            mut.blurType = currentBlurType
            mut.blurIntensity = currentLineWidth
            currentShapeAnnotation = mut
        case .eraser:
            break
        }
    }

    func handleDragMove(at point: CGPoint, imageSize: CGSize, viewSize: CGSize) {
        let scaledPoint = scalePoint(point, imageSize: imageSize, viewSize: viewSize)

        switch currentTool {
        case .loupe, .shape, .blur:
            if var annotation = currentShapeAnnotation {
                let dx = scaledPoint.x - annotation.position.x
                let dy = scaledPoint.y - annotation.position.y
                annotation.size = CGSize(width: abs(dx) * 2, height: abs(dy) * 2)
                currentShapeAnnotation = annotation
            }
        case .arrow:
            if var annotation = currentArrowAnnotation {
                annotation.endPoint = scaledPoint
                currentArrowAnnotation = annotation
            }
        case .pen, .marker, .pencil, .highlight:
            if var annotation = currentDrawingAnnotation {
                annotation.pathPoints?.append(PathPoint(x: scaledPoint.x, y: scaledPoint.y))
                currentDrawingAnnotation = annotation
            }
        case .text, .eraser:
            break
        }
    }

    func handleDragEnd() {
        isDrawing = false

        if let annotation = currentShapeAnnotation {
            annotations.append(annotation)
            currentShapeAnnotation = nil
        }
        if let annotation = currentArrowAnnotation {
            annotations.append(annotation)
            currentArrowAnnotation = nil
        }
        if let annotation = currentDrawingAnnotation {
            if let points = annotation.pathPoints, points.count > 1 {
                annotations.append(annotation)
            }
            currentDrawingAnnotation = nil
        }

        toolMemory.updateLineWidth(currentLineWidth)
        toolMemory.updateOpacity(currentOpacity)
    }

    func currentDrawingAnnotations() -> [Annotation] {
        var result = annotations
        if let annotation = currentShapeAnnotation {
            result.append(annotation)
        }
        if let annotation = currentArrowAnnotation {
            result.append(annotation)
        }
        if let annotation = currentDrawingAnnotation {
            result.append(annotation)
        }
        return result
    }

    func exportAndSave(format: ExportFormat) async -> Bool {
        let service = ExportService()
        return await service.saveToPhotos(annotations: annotations, image: sourceImage, format: format)
    }

    private func scalePoint(_ point: CGPoint, imageSize: CGSize, viewSize: CGSize) -> CGPoint {
        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height

        var fittedSize: CGSize
        var offset: CGPoint

        if imageAspect > viewAspect {
            fittedSize = CGSize(width: viewSize.width, height: viewSize.width / imageAspect)
            offset = CGPoint(x: 0, y: (viewSize.height - fittedSize.height) / 2)
        } else {
            fittedSize = CGSize(width: viewSize.height * imageAspect, height: viewSize.height)
            offset = CGPoint(x: (viewSize.width - fittedSize.width) / 2, y: 0)
        }

        let adjustedPoint = CGPoint(x: point.x - offset.x, y: point.y - offset.y)
        let scaleX = imageSize.width / fittedSize.width
        let scaleY = imageSize.height / fittedSize.height

        return CGPoint(x: adjustedPoint.x * scaleX, y: adjustedPoint.y * scaleY)
    }
}
