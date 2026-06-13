import SwiftUI

struct SettingsView: View {
    @State var viewModel: SettingsViewModel

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            List {
                Section {
                    Button(action: { viewModel.importDataTapped() }) {
                        Label(.importData, systemImage: "square.and.arrow.down")
                    }
                    #if DEBUG
                    Button(action: { viewModel.useTestDataTapped() }) {
                        Label(.useTestData, systemImage: "wrench.and.screwdriver.fill")
                    }
                    #endif
                }
                Section(.mapSettings) {
                    Toggle(.showPolygons, isOn: $viewModel.shouldShowPolygonsOnMap)
                    Toggle(.showPolylines, isOn: $viewModel.shouldShowPolylinesOnMap)
                }
            }
            .navigationTitle(.settings)
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

// MARK: - Previews

#Preview {
    SettingsView(viewModel: SettingsPreviews.viewModel)
}
