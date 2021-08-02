import SwiftUI
import UniformTypeIdentifiers

struct SettingsDocumentPicker: UIViewControllerRepresentable {
    weak var delegate: UIDocumentPickerDelegate?

    func makeUIViewController(context: Context) -> some UIViewController {
        let contentTypeKML = UTType("public.kml")
        let contentTypes = [contentTypeKML].compactMap { $0 }
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: true)
        controller.delegate = delegate
        controller.allowsMultipleSelection = false
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // No-op
    }
}
