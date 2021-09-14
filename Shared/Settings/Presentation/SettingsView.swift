import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel

    var body: some View {
        NavigationView {
            List {
                SettingsItemView(imageName: "square.and.arrow.down", name: "settings.import.data")
                    .onTapGesture {
                        viewModel.importDataTapped()
                    }
            }
            .navigationTitle("settings.title")
        }
        .navigationViewStyle(StackNavigationViewStyle())
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

struct SettingsViewPreviews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsPreviews.viewModel)
    }
}
