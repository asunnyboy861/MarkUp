# MarkUp - iOS Development Guide

## Executive Summary

**MarkUp — Photo Markup & Annotation** is a premium photo annotation tool that restores and surpasses the Markup features removed or degraded in iOS 17/18. The app targets the global 1B+ iPhone users who lost the Magnifier/Loupe tool, hollow shape outlines, free-angle arrows, and reliable color pickers. MarkUp differentiates by combining all lost features with modern enhancements: tool memory, adjustable opacity, batch editing, and template presets.

**Product Vision**: "The markup tool Apple should have built" — restore every removed feature, then evolve beyond.

**Target Audience**: Business professionals, educators, developers, designers, and everyday iPhone users who annotate screenshots, photos, and documents.

**Key Differentiators**:
- Restored Magnifier/Loupe (works on ALL image types, not just screenshots like iOS 26)
- Hollow shape outlines by default (not filled like iOS 17+)
- Free-angle arrows (not snapped to 0°/45°/90°)
- Tool/color/thickness memory across sessions
- Adjustable opacity for all tools
- Batch annotation across multiple images
- Template/preset system for repeated workflows

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| **iOS Native Markup** | Free, system-integrated, no install needed | Removed Magnifier; shapes default filled; arrows snap to angles; no tool memory; color picker crashes in iOS 18 | Restore all removed features + tool memory + batch editing |
| **Annotable** | 4.5★, Apple-featured, Loupe tool, Spotlight | Fragmented IAP ($1.99 per tool); last updated Nov 2023; UI dated; iOS 15+ only | Unified feature set; modern SwiftUI UI; continuous updates; no fragmented pricing |
| **iMark** | Free, has Magnifier | 3.5★; giant watermark; poor Magnifier quality; cluttered UI | No watermark; professional Magnifier; clean minimal UI |
| **Snap Markup** | 4.6★, free + IAP, multiple tools | Drawing calibration drift; annotations can't move; loupe shape not adjustable | Precise drawing; movable annotations; adjustable loupe |
| **Skitch (Evernote)** | Was popular, free | Discontinued; requires Evernote account; outdated features | Actively maintained; standalone; modern feature set |

## Feature Inventory

### Primary Features

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 1 | Magnifier/Loupe Tool | 1. Tap Loupe icon → 2. Drag to position → 3. Pinch to resize → 4. Drag green handle to adjust zoom | Touch position, pinch scale | Calculate circular crop region, apply zoom transform, render border | Circular magnified overlay on image | Annotation model: type=loupe, position, radius, zoomLevel | Loupe appears at touch point; content inside magnified 2-8x; border visible; movable |
| 2 | Shape Tools (Hollow + Filled) | 1. Tap Shape icon → 2. Select shape (circle/rect/triangle/star) → 3. Drag to draw → 4. Toggle fill/outline | Shape type, drag bounds, fill mode | Calculate shape path from bounds, apply fill/stroke style | Shape overlay on image | Annotation model: type=shape, shapeType, bounds, isFilled, color, lineWidth | Shapes render as hollow outlines by default; toggle to filled; resizable; movable |
| 3 | Arrow Tool (Free Angle) | 1. Tap Arrow icon → 2. Drag from start to end → 3. Arrow renders at exact drag angle | Start point, end point | Calculate arrow path with arrowhead at correct angle | Arrow overlay on image | Annotation model: type=arrow, startPoint, endPoint, color, lineWidth | Arrow follows exact finger angle; no snapping to 0°/45°/90°; arrowhead renders correctly |
| 4 | Text Annotation | 1. Tap Text icon → 2. Tap on image → 3. Type text → 4. Adjust font/size/color → 5. Drag to position | Text string, font, size, color | Render text with selected style at position | Text overlay on image | Annotation model: type=text, content, font, fontSize, color, position | Text appears at tap location; editable; font/size/color adjustable; draggable |
| 5 | Free Drawing | 1. Tap Pen/Marker/Pencil icon → 2. Draw on image → 3. Adjust thickness/opacity | Touch path points, tool type, thickness, opacity | Render stroke path with PencilKit, apply opacity | Drawing overlay on image | Annotation model: type=drawing, pathData, toolType, color, lineWidth, opacity | Smooth drawing with low latency; thickness/opacity adjustable; supports Apple Pencil |
| 6 | Highlight Tool | 1. Tap Highlight icon → 2. Drag over area → 3. Semi-transparent color overlay appears | Touch path, color, opacity | Render semi-transparent stroke over image area | Highlight overlay on image | Annotation model: type=highlight, pathData, color, opacity | Semi-transparent highlight; opacity adjustable 10-90%; does not obscure underlying content |
| 7 | Blur/Pixelate/Mosaic | 1. Tap Blur icon → 2. Drag over area → 3. Selected area blurred/pixelated | Touch path, blur type, intensity | Apply CIGaussianBlur or CIPixellate filter to region | Blurred/pixelated region on image | Annotation model: type=blur, pathData, blurType, intensity | Area obscured; blur intensity adjustable; pixelate size adjustable; no visible seams |
| 8 | Opacity Adjustment | 1. Select any annotation → 2. Drag opacity slider → 3. Real-time preview | Opacity value 0-100% | Apply opacity to selected annotation's rendering | Annotation rendered at new opacity | Annotation model: opacity property updated | All annotations support opacity; real-time preview; slider responsive |
| 9 | Tool Memory | 1. Use any tool with settings → 2. Close app → 3. Reopen → 4. Same tool/settings restored | Last used: tool type, color, lineWidth, opacity | Save to UserDefaults on change; load on app launch | Previous tool auto-selected | UserDefaults: lastTool, lastColor, lastLineWidth, lastOpacity | App remembers last tool, color, thickness, opacity across sessions |
| 10 | Photo Library Import | 1. Open app → 2. Photo grid displayed → 3. Tap photo → 4. Editor opens | PHAsset selection | Load PHAsset → UIImage → display in editor | Image loaded in canvas | None (read from Photos framework) | Photos displayed in grid; tapping opens editor; full resolution supported |
| 11 | Camera Capture | 1. Tap camera icon → 2. Take photo → 3. Editor opens with captured photo | Camera capture output | Convert camera output to UIImage | Image loaded in canvas | Save to Photos if user confirms | Camera launches; captured photo opens in editor |
| 12 | Share Extension Import | 1. In any app → 2. Tap Share → 3. Select MarkUp → 4. Editor opens | Shared image data (URL/Data) | Convert shared data to UIImage | Image loaded in canvas | None (from share extension) | MarkUp appears in share sheet; image opens in editor |
| 13 | Export & Share | 1. Tap Done → 2. Choose format (PNG/JPG/PDF) → 3. Save to Photos or Share | Format selection, quality | Render all annotations onto image; encode in selected format | Exported file | Saved to Photos or shared via UIActivityViewController | Export at full resolution; PNG/JPG/PDF supported; auto-save to Photos option |
| 14 | Batch Editing | 1. Long-press to select multiple photos → 2. Tap Edit → 3. Apply same annotations to all | Multiple PHAssets, shared annotation set | Clone annotations across images; render each | Multiple annotated images | None | Select 2-20 photos; apply same tool to all; export all |
| 15 | Template/Presets | 1. Create annotation set → 2. Tap Save as Template → 3. Name template → 4. Apply to new image | Template name, annotation data | Serialize annotations to JSON; deserialize on apply | Template list | UserDefaults/JSON: templates array | Save/load templates; apply to new images; delete templates |
| 16 | Undo/Redo | 1. Tap undo/redo button OR 2. Shake device | Undo/redo action | Pop/push annotation from history stack | Canvas updated | In-memory: undoStack, redoStack | Undo removes last annotation; redo restores; shake-to-undo works |
| 17 | Color Picker | 1. Tap color swatch → 2. Color picker appears and STAYS → 3. Select color → 4. Picker dismisses | Color selection | Update current tool color | Color applied to tool | UserDefaults: lastColor | Picker stays visible until dismissed; no crash; full color spectrum; recent colors |

### Sub-Features & Detail Interactions

| # | Parent Feature | Sub-Feature | Detail Description | Interaction Pattern |
|---|---------------|-------------|-------------------|--------------------|
| 1.1 | Magnifier/Loupe | Adjustable Zoom Level | Green handle controls zoom from 2x to 8x | Drag green handle |
| 1.2 | Magnifier/Loupe | Adjustable Size | Blue handle controls loupe circle size | Drag blue handle |
| 1.3 | Magnifier/Loupe | Move Loupe | Drag loupe to reposition | Touch and drag |
| 2.1 | Shape Tools | Fill/Outline Toggle | Toggle between hollow outline and filled shape | Tap fill toggle button |
| 2.2 | Shape Tools | Shape Type Selection | Choose circle, rectangle, triangle, star, chat bubble | Tap shape selector |
| 3.1 | Arrow Tool | Arrowhead Style | Choose open or filled arrowhead | Tap style button |
| 4.1 | Text Annotation | Font Selection | Choose from system fonts | Tap font picker |
| 4.2 | Text Annotation | Text Resize | Pinch to resize text | Pinch gesture |
| 5.1 | Free Drawing | Tool Type Selection | Pen, Marker, Pencil with different stroke styles | Tap tool selector |
| 5.2 | Free Drawing | Thickness Adjustment | Slider to adjust line width 1-20pt | Drag slider |
| 6.1 | Highlight | Color Selection | Choose highlight color from palette | Tap color swatch |
| 7.1 | Blur/Pixelate | Blur Type Toggle | Switch between Gaussian blur and pixelation | Tap toggle |
| 7.2 | Blur/Pixelate | Intensity Adjustment | Slider to adjust blur radius or pixel size | Drag slider |
| 9.1 | Tool Memory | Per-Tool Memory | Each tool remembers its own last-used settings | Automatic |
| 10.1 | Photo Library | Grid View | Photos displayed in chronological grid | Scroll |
| 10.2 | Photo Library | Smart Album | Screenshots album for quick access | Tap album tab |
| 13.1 | Export | Auto-Save to Photos | Option to automatically save annotated images | Toggle in settings |
| 14.1 | Batch Editing | Apply to All | Apply current annotation to all selected images | Tap "Apply to All" |
| 15.1 | Templates | Template Gallery | Browse saved templates with preview | Tap template to preview |
| 15.2 | Templates | Delete Template | Swipe to delete saved template | Swipe left |
| 17.1 | Color Picker | Recent Colors | Show last 8 used colors for quick access | Tap recent color |
| 17.2 | Color Picker | Custom Color | Full spectrum color wheel with brightness slider | Drag on wheel + slider |

### Cross-Feature Dependencies

| Dependency | Source Feature | Target Feature | Data Passed | Trigger Condition |
|------------|---------------|----------------|-------------|-------------------|
| Tool selection affects new annotations | Tool Memory (9) | All annotation tools (1-7) | lastTool, lastColor, lastLineWidth, lastOpacity | App launch, tool switch |
| Color picker updates current tool | Color Picker (17) | All annotation tools (1-7) | Selected color | Color selected in picker |
| Undo removes annotation | Undo/Redo (16) | Canvas rendering | Removed annotation from stack | Undo button tapped or shake |
| Template applies annotations | Template/Presets (15) | Canvas rendering | Deserialized annotation array | Template selected |
| Export renders all annotations | Export & Share (13) | All annotation tools (1-7) | All current annotations | Export triggered |
| Batch clones annotations | Batch Editing (14) | All annotation tools (1-7) | Annotation set to clone | "Apply to All" tapped |
| Photo import provides canvas image | Photo Library (10) / Camera (11) / Share (12) | Canvas rendering | UIImage for canvas background | Image selected/captured/shared |

## Apple Design Guidelines Compliance

- **HIG: Navigation**: Tab-based navigation for Home/Settings; modal editor for annotation
- **HIG: Modality**: Full-screen editor for annotation; no nested modals
- **HIG: Gestures**: Pinch to zoom canvas; drag to move annotations; long-press for context menus
- **HIG: Color**: System color palette; support for Dark Mode; dynamic colors
- **HIG: Typography**: SF Pro system font; Dynamic Type support for text annotations
- **HIG: Haptics**: Subtle haptic feedback on tool selection, shape snap, export completion
- **HIG: Accessibility**: VoiceOver labels for all tools; Dynamic Type; reduced motion support
- **HIG: Photos Privacy**: NSPhotoLibraryUsageDescription required; read-only access for import
- **HIG: Camera Privacy**: NSCameraUsageDescription required for camera capture
- **App Store 2.1**: App must be fully functional; no placeholder features
- **App Store 3.1.2**: IAP must clearly describe what users get; no deceptive pricing
- **App Store 4.0**: Design minimum; follow iOS design language; no custom UI that confuses users

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary), PencilKit (drawing), UIKit (canvas overlay)
- **Data**: UserDefaults (tool memory, templates), Photos Framework (image import)
- **Image Processing**: Core Image (blur, pixelate), Metal (canvas rendering)
- **Architecture**: MVVM (ObservableObject + @Published + Combine)
- **Minimum iOS**: 17.0
- **Device**: iPhone and iPad (Universal)

## Module Structure

```
MarkUp/
├── MarkUpApp.swift
├── Views/
│   ├── Home/
│   │   ├── PhotoGridView.swift
│   │   └── PhotoGridViewModel.swift
│   ├── Editor/
│   │   ├── EditorView.swift
│   │   ├── EditorViewModel.swift
│   │   ├── CanvasView.swift
│   │   ├── ToolBarView.swift
│   │   └── ColorPickerView.swift
│   ├── Templates/
│   │   ├── TemplateListView.swift
│   │   └── TemplateListViewModel.swift
│   ├── Batch/
│   │   ├── BatchEditView.swift
│   │   └── BatchEditViewModel.swift
│   └── Settings/
│       ├── SettingsView.swift
│       └── SettingsViewModel.swift
├── Models/
│   ├── Annotation.swift
│   ├── ToolType.swift
│   ├── Template.swift
│   └── ExportFormat.swift
├── Services/
│   ├── ImageImportService.swift
│   ├── AnnotationRenderer.swift
│   ├── ExportService.swift
│   ├── TemplateService.swift
│   └── ToolMemoryService.swift
├── Extensions/
│   ├── Color+Extensions.swift
│   ├── UIImage+Extensions.swift
│   └── View+Extensions.swift
└── Resources/
    └── Assets.xcassets/
```

## Data Flow Diagram

```
Feature: Photo Import & Canvas Display
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap photo in grid / Camera capture / Share extension │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── PhotoGridViewModel → request PHAsset → load UIImage │
│       │                                                   │
│  Model/Persistence                                        │
│  └── Photos Framework (PHAsset) → UIImage cache           │
│       │                                                   │
│  Display Output                                           │
│  └── EditorView → CanvasView renders UIImage as background│
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── UIImage passed to AnnotationRenderer for export      │
└───────────────────────────────────────────────────────────┘

Feature: Annotation Creation (all tools)
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Select tool → Touch/drag on canvas → Adjust params  │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── EditorViewModel → create Annotation model → add to   │
│      annotations array → push to undoStack                │
│       │                                                   │
│  Model/Persistence                                        │
│  └── Annotation struct (type, position, size, color, etc.)│
│      In-memory: [Annotation] array                        │
│       │                                                   │
│  Display Output                                           │
│  └── CanvasView → AnnotationRenderer.draw(annotation)     │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Undo/Redo stack; Template serialization; Export      │
└───────────────────────────────────────────────────────────┘

Feature: Tool Memory
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Change tool/color/thickness/opacity                  │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── EditorViewModel → update currentSettings → save()    │
│       │                                                   │
│  Model/Persistence                                        │
│  └── ToolMemoryService → UserDefaults (lastTool, etc.)    │
│       │                                                   │
│  Display Output                                           │
│  └── ToolBarView highlights last-used tool and settings   │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── On app launch, restore last tool settings            │
└───────────────────────────────────────────────────────────┘

Feature: Export & Share
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap Done → Select format → Save/Share                │
│       │                                                   │
│  ViewModel Processing                                     │
│  └── EditorViewModel → ExportService.render(annotations)  │
│       │                                                   │
│  Model/Persistence                                        │
│  └── AnnotationRenderer → composite image + annotations   │
│      → encode as PNG/JPG/PDF                              │
│       │                                                   │
│  Display Output                                           │
│  └── UIActivityViewController / Photos save                │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Saved to Photos album; shared to other apps          │
└───────────────────────────────────────────────────────────┘

Feature: Template System
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Save current annotations as template / Apply template│
│       │                                                   │
│  ViewModel Processing                                     │
│  └── TemplateListViewModel → serialize/deserialize        │
│       │                                                   │
│  Model/Persistence                                        │
│  └── Template model → JSON → UserDefaults                 │
│       │                                                   │
│  Display Output                                           │
│  └── Template list with preview thumbnails                │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Applied template creates annotations on current image│
└───────────────────────────────────────────────────────────┘
```

## Implementation Flow

1. Set up Xcode project with SwiftUI, MVVM architecture, and universal device support
2. Implement Photo Library import with Photos Framework (grid view, asset loading)
3. Implement Camera capture integration
4. Build Canvas rendering engine (Metal/Core Image for image display)
5. Implement Magnifier/Loupe tool with adjustable zoom and size
6. Implement Shape tools (circle, rect, triangle, star) with fill/outline toggle
7. Implement Arrow tool with free-angle rendering
8. Implement Text annotation with font/size/color customization
9. Implement Free Drawing with PencilKit integration
10. Implement Highlight tool with adjustable opacity
11. Implement Blur/Pixelate tool with intensity control
12. Implement Opacity adjustment for all annotations
13. Implement Undo/Redo with history stack
14. Implement Color Picker (stable, no crash, recent colors)
15. Implement Tool Memory (UserDefaults persistence)
16. Implement Export & Share (PNG/JPG/PDF, UIActivityViewController)
17. Implement Share Extension for image import from other apps
18. Implement Template/Presets system (save/load/apply)
19. Implement Batch Editing (multi-select, apply annotations to all)
20. Polish UI/UX (animations, haptics, Dark Mode, accessibility)
21. Configure IAP and subscription if needed
22. Add Settings view with preferences
23. Test on iPhone and iPad simulators
24. Prepare App Store metadata and submit

## UI/UX Design Specifications

- **Color Scheme**: System-based (adaptive light/dark); primary accent = system blue; tool colors = full spectrum palette
- **Typography**: SF Pro (system); Dynamic Type support; annotation text supports multiple fonts
- **Layout**: 
  - Home: Photo grid with tab bar (Photos / Screenshots / Templates)
  - Editor: Full-screen canvas with bottom tool bar and top action bar
  - Tool bar: Horizontally scrollable with tool icons; active tool highlighted
  - Settings: Standard grouped list style
- **Animations**: 
  - Tool selection: Scale + haptic feedback
  - Annotation creation: Smooth real-time rendering
  - Export: Progress indicator with completion haptic
  - Page transitions: Standard iOS navigation transitions
- **Gestures**:
  - Single tap: Select tool, place text
  - Drag: Draw, move annotations, resize
  - Pinch: Zoom canvas, resize annotations
  - Long-press: Context menu, move annotations
  - Shake: Undo
- **Accessibility**: VoiceOver labels for all interactive elements; Dynamic Type; reduced motion; high contrast support

## Code Generation Rules

- One feature per module, high cohesion, low coupling
- Semantic naming, clear file structure
- Never add comments in code unless asked
- Apple native first: prioritize SwiftUI, PencilKit, Core Image
- MVVM pattern: View → ViewModel → Service/Model
- All annotations as value types (struct) for undo/redo simplicity
- UserDefaults for lightweight persistence (tool memory, templates)
- Photos Framework for image import (no third-party image libraries)
- PencilKit for free drawing (Apple's native framework)
- Core Image for blur/pixelate effects
- No third-party dependencies unless absolutely necessary

## Build & Deployment Checklist

- [ ] Xcode project configured with Bundle ID com.zzoutuo.MarkUp
- [ ] Minimum iOS 17.0 deployment target
- [ ] Universal (iPhone + iPad) support
- [ ] NSPhotoLibraryUsageDescription in Info.plist
- [ ] NSCameraUsageDescription in Info.plist
- [ ] App icon generated and configured
- [ ] Launch screen configured
- [ ] Build succeeds for iPhone and iPad simulators
- [ ] All 17 primary features implemented and tested
- [ ] Dark Mode supported
- [ ] VoiceOver accessibility verified
- [ ] No crashes on color picker or tool switching
- [ ] Export produces correct PNG/JPG/PDF output
- [ ] Share Extension functional
- [ ] IAP configured (if applicable)
- [ ] Privacy Policy page deployed
- [ ] Support page deployed
- [ ] Terms of Use page deployed (if IAP/subscription)
- [ ] App Store metadata prepared
