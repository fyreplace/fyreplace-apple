import SwiftUI

struct EnvironmentPicker: View {
    let namespace: Namespace.ID

    @AppStorage("connection.environment")
    private var selectedEnvironment = ServerEnvironment.default

    var body: some View {
        Picker("Environment.Title", selection: $selectedEnvironment) {
            ForEach(ServerEnvironment.allCases) { environment in
                let suffix = environment == .default
                    ? " " + .init(localized: "Environment.Default")
                    : ""

                Text(verbatim: environment.description + suffix)
                    .tag(environment)
            }
        }
        .help("Environment.Help")
        .matchedGeometryEffect(id: "environment-picker", in: namespace)
    }
}
