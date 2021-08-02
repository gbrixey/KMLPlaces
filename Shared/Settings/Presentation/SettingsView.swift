import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel

    var body: some View {
        NavigationView {
            List {
                Text("settings.import.data")
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .onTapGesture {
                        viewModel.importDataTapped()
                    }
            }
            .navigationTitle("settings.title")
        }
        .sheet(isPresented: $viewModel.showDocumentPicker) {
            SettingsDocumentPicker(delegate: viewModel)
        }
    }
}

// MARK: - Previews

struct SettingsViewPreviews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsPreviews.viewModel)
    }
}
