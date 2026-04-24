import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            List {
                SettingsItemView(imageName: "square.and.arrow.down", name: "settings.import.data")
                    .onTapGesture {
                        viewModel.importDataTapped()
                    }
                #if DEBUG
                // TODO: Add some kind of success view when the data is successfully parsed.
                SettingsItemView(imageName: "wrench.and.screwdriver.fill", name: "settings.test.data")
                    .onTapGesture {
                        viewModel.useTestDataTapped()
                    }
                #endif
            }
            .navigationTitle("settings.title")
        }
        .sheet(isPresented: $viewModel.showDocumentPicker) {
            SettingsDocumentPicker(delegate: viewModel)
        }
    }
}

// MARK: - Additional views

extension SettingsView {

    struct SettingsItemView: View {
        let imageName: String
        let name: LocalizedStringKey

        var body: some View {
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

// MARK: - Previews

#Preview {
    SettingsView(viewModel: SettingsPreviews.viewModel)
}
