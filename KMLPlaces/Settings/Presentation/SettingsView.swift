import SwiftUI

struct SettingsView: View {
    @State var viewModel: SettingsViewModel

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            List {
                Section {
                    SettingsButton(
                        imageName: "square.and.arrow.down",
                        name: String(localized: .importData),
                        action: { viewModel.importDataTapped() }
                    )
#if DEBUG
                    SettingsButton(
                        imageName: "wrench.and.screwdriver.fill",
                        name: String(localized: .useTestData),
                        action: { viewModel.useTestDataTapped() }
                    )
#endif
                }
                Section(.mapSettings) {
                    Toggle(String(localized: .showPolygons), isOn: $viewModel.shouldShowPolygonsOnMap)
                    Toggle(String(localized: .showPolylines), isOn: $viewModel.shouldShowPolylinesOnMap)
                }
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $viewModel.showDocumentPicker) {
            SettingsDocumentPicker(delegate: viewModel)
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
            // Default OK action
        } message: {
            Text(viewModel.alertMessage)
        }

    }
}

// MARK: - Additional views

extension SettingsView {

    struct SettingsButton: View {
        let imageName: String
        let name: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: 0) {
                    Image(systemName: imageName)
                        .frame(width: 30)
                        .padding(.trailing, 10)
                        .foregroundColor(.blue)
                    Text(name)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(name)
                .contentShape(Rectangle())
            }
        }
    }
}

// MARK: - Previews

#Preview {
    SettingsView(viewModel: SettingsPreviews.viewModel)
}
